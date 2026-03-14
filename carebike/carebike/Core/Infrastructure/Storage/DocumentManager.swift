import Foundation
import SwiftData
import UniformTypeIdentifiers

@MainActor
class DocumentManager: ObservableObject {
    static let shared = DocumentManager()
    
    @Published var isExporting = false
    @Published var isImporting = false
    @Published var exportURL: URL?
    @Published var importError: Error?
    
    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func exportData(modelContext: ModelContext) async throws -> URL {
        isExporting = true
        defer { isExporting = false }
        
        var exportData = ExportData()
        
        let bikeDescriptor = FetchDescriptor<Bicycle>()
        let componentDescriptor = FetchDescriptor<Component>()
        let maintenanceDescriptor = FetchDescriptor<MaintenanceEvent>()
        let rideDescriptor = FetchDescriptor<Ride>()
        let costDescriptor = FetchDescriptor<CostEntry>()
        
        exportData.bicycles = try modelContext.fetch(bikeDescriptor)
        exportData.components = try modelContext.fetch(componentDescriptor)
        exportData.maintenanceEvents = try modelContext.fetch(maintenanceDescriptor)
        exportData.rides = try modelContext.fetch(rideDescriptor)
        exportData.costEntries = try modelContext.fetch(costDescriptor)
        exportData.exportDate = Date()
        exportData.appVersion = Constants.App.version
        
        let data = try jsonEncoder.encode(exportData)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = dateFormatter.string(from: Date())
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("BikeCare_Export_\(dateString)")
            .appendingPathExtension("json")
        
        try data.write(to: tempURL)
        exportURL = tempURL
        
        return tempURL
    }
    
    func importData(from url: URL, modelContext: ModelContext) async throws {
        isImporting = true
        defer { isImporting = false }
        
        guard url.startAccessingSecurityScopedResource() else {
            throw DocumentError.accessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let data = try Data(contentsOf: url)
        let importData = try jsonDecoder.decode(ExportData.self, from: data)
        
        if let version = importData.appVersion, !isCompatibleVersion(version) {
            throw DocumentError.incompatibleVersion
        }
        
        for bike in importData.bicycles {
            modelContext.insert(bike)
        }
        
        for component in importData.components {
            modelContext.insert(component)
        }
        
        for event in importData.maintenanceEvents {
            modelContext.insert(event)
        }
        
        for ride in importData.rides {
            modelContext.insert(ride)
        }
        
        for entry in importData.costEntries {
            modelContext.insert(entry)
        }
        
        try modelContext.save()
    }
    
    func clearAllData(modelContext: ModelContext) throws {
        let bikeDescriptor = FetchDescriptor<Bicycle>()
        let componentDescriptor = FetchDescriptor<Component>()
        let maintenanceDescriptor = FetchDescriptor<MaintenanceEvent>()
        let rideDescriptor = FetchDescriptor<Ride>()
        let costDescriptor = FetchDescriptor<CostEntry>()
        
        let bikes = try modelContext.fetch(bikeDescriptor)
        let components = try modelContext.fetch(componentDescriptor)
        let events = try modelContext.fetch(maintenanceDescriptor)
        let rides = try modelContext.fetch(rideDescriptor)
        let entries = try modelContext.fetch(costDescriptor)
        
        for bike in bikes { modelContext.delete(bike) }
        for component in components { modelContext.delete(component) }
        for event in events { modelContext.delete(event) }
        for ride in rides { modelContext.delete(ride) }
        for entry in entries { modelContext.delete(entry) }
        
        try modelContext.save()
    }
    
    private func isCompatibleVersion(_ version: String) -> Bool {
        let currentParts = Constants.App.version.split(separator: ".").compactMap { Int($0) }
        let importParts = version.split(separator: ".").compactMap { Int($0) }
        
        guard currentParts.count >= 1 && importParts.count >= 1 else { return false }
        
        return currentParts[0] == importParts[0]
    }
}

struct ExportData: Codable {
    var bicycles: [Bicycle] = []
    var components: [Component] = []
    var maintenanceEvents: [MaintenanceEvent] = []
    var rides: [Ride] = []
    var costEntries: [CostEntry] = []
    var exportDate: Date?
    var appVersion: String?
}

enum DocumentError: LocalizedError {
    case accessDenied
    case incompatibleVersion
    case encodingFailed
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Access to the file was denied"
        case .incompatibleVersion:
            return "The file was created with an incompatible version of the app"
        case .encodingFailed:
            return "Failed to encode data for export"
        case .decodingFailed:
            return "Failed to decode the imported file"
        }
    }
}
