import Foundation
import SwiftData

@MainActor
class BikeListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedBikeType: BikeType?
    
    func filterBikes(_ bikes: [Bicycle]) -> [Bicycle] {
        var filtered = bikes
        
        if !searchText.isEmpty {
            filtered = filtered.filter { bike in
                bike.name.localizedCaseInsensitiveContains(searchText) ||
                bike.brand.localizedCaseInsensitiveContains(searchText) ||
                bike.model.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let type = selectedBikeType {
            filtered = filtered.filter { $0.bikeType == type }
        }
        
        return filtered
    }
    
    func getBikesNeedingMaintenance(_ bikes: [Bicycle]) -> [Bicycle] {
        bikes.filter { $0.needsMaintenance }
    }
    
    func getMostRiddenBike(_ bikes: [Bicycle]) -> Bicycle? {
        bikes.max(by: { $0.totalDistance < $1.totalDistance })
    }
    
    func getTotalDistance(_ bikes: [Bicycle]) -> Double {
        bikes.reduce(0) { $0 + $1.totalDistance }
    }
    
    func getTotalMaintenanceCost(_ bikes: [Bicycle]) -> Double {
        bikes.reduce(0) { $0 + $1.totalMaintenanceCost }
    }
}
