import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage(Constants.Storage.preferredDistanceUnit) private var preferredDistanceUnit = DistanceUnit.kilometers.rawValue
    @AppStorage(Constants.Storage.notificationsEnabled) private var notificationsEnabled = true
    @AppStorage("maintenanceReminders") private var maintenanceReminders = true
    @AppStorage("componentAlerts") private var componentAlerts = true
    
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var documentManager = DocumentManager.shared
    
    @State private var showExportSheet = false
    @State private var showImportPicker = false
    @State private var showClearConfirmation = false
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""
    @State private var showContactSupport = false
    
    var body: some View {
        NavigationStack {
            List {
                unitsSection
                notificationsSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .confirmationDialog(
                "Clear All Data",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Data", role: .destructive) {
                    performClearData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete all your bikes, components, rides, and maintenance records. This action cannot be undone.")
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = documentManager.exportURL {
                    ShareSheet(items: [url])
                }
            }
            .fileImporter(
                isPresented: $showImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImportResult(result)
            }
            .sheet(isPresented: $showContactSupport) {
                ContactSupportView()
            }
        }
    }
    
    private var unitsSection: some View {
        Section {
            Picker("Distance Unit", selection: $preferredDistanceUnit) {
                ForEach(DistanceUnit.allCases, id: \.rawValue) { unit in
                    Text(unit.fullName).tag(unit.rawValue)
                }
            }
            .pickerStyle(.navigationLink)
        } header: {
            Text("Units")
        }
    }
    
    private var notificationsSection: some View {
        Section {
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { _, newValue in
                    if newValue {
                        Task {
                            _ = await notificationManager.requestAuthorization()
                        }
                    }
                }
            
            Toggle("Maintenance Reminders", isOn: $maintenanceReminders)
                .disabled(!notificationsEnabled)
            
            Toggle("Component Alerts", isOn: $componentAlerts)
                .disabled(!notificationsEnabled)
        } header: {
            Text("Notifications")
        } footer: {
            Text("Get reminded about scheduled maintenance and component replacements")
        }
    }
    
    private var dataSection: some View {
        Section {
            Button(action: performExport) {
                HStack {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                    Spacer()
                    if documentManager.isExporting {
                        ProgressView()
                    }
                }
            }
            .disabled(documentManager.isExporting)
            
            Button(action: { showImportPicker = true }) {
                HStack {
                    Label("Import Data", systemImage: "square.and.arrow.down")
                    Spacer()
                    if documentManager.isImporting {
                        ProgressView()
                    }
                }
            }
            .disabled(documentManager.isImporting)
            
            Button(role: .destructive, action: { showClearConfirmation = true }) {
                Label("Clear All Data", systemImage: "trash")
            }
        } header: {
            Text("Data")
        }
    }
    
    private var aboutSection: some View {
        Section {
            LabeledContent("Version", value: Constants.App.version)
            LabeledContent("Build", value: Constants.App.build)
            
            Link(destination: URL(string: "https://bikecare.app/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.shield")
            }
            
            Link(destination: URL(string: "https://bikecare.app/terms")!) {
                Label("Terms of Service", systemImage: "doc.text")
            }
            
            Button(action: { showContactSupport = true }) {
                Label("Contact Support", systemImage: "envelope")
            }
        } header: {
            Text("About")
        }
    }
    
    private func performExport() {
        Task {
            do {
                _ = try await documentManager.exportData(modelContext: modelContext)
                showExportSheet = true
            } catch {
                alertMessage = "Export failed: \(error.localizedDescription)"
                showSuccessAlert = true
            }
        }
    }
    
    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            Task {
                do {
                    try await documentManager.importData(from: url, modelContext: modelContext)
                    alertMessage = "Data imported successfully"
                    showSuccessAlert = true
                } catch {
                    alertMessage = "Import failed: \(error.localizedDescription)"
                    showSuccessAlert = true
                }
            }
        case .failure(let error):
            alertMessage = "Import failed: \(error.localizedDescription)"
            showSuccessAlert = true
        }
    }
    
    private func performClearData() {
        do {
            try documentManager.clearAllData(modelContext: modelContext)
            alertMessage = "All data has been cleared"
            showSuccessAlert = true
        } catch {
            alertMessage = "Failed to clear data: \(error.localizedDescription)"
            showSuccessAlert = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
}
