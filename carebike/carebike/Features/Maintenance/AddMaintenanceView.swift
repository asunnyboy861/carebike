import SwiftUI
import SwiftData

struct AddMaintenanceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var bicycle: Bicycle?
    var component: Component?
    
    @State private var title = ""
    @State private var maintenanceType: MaintenanceType = .routine
    @State private var description = ""
    @State private var cost = ""
    @State private var distance = ""
    @State private var isScheduled = false
    @State private var scheduledDate = Date()
    @State private var notes = ""
    @State private var selectedBicycle: Bicycle?
    @State private var selectedComponent: Component?
    
    @Query(sort: \Bicycle.name) private var bicycles: [Bicycle]
    
    init(bicycle: Bicycle? = nil, component: Component? = nil) {
        self.bicycle = bicycle
        self.component = component
    }
    
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                costSection
                schedulingSection
                bikeSelectionSection
            }
            .navigationTitle("Log Maintenance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveMaintenance()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                selectedBicycle = bicycle ?? bicycles.first
                selectedComponent = component
            }
        }
    }
    
    private var basicInfoSection: some View {
        Section {
            TextField("Title", text: $title)
            
            Picker("Type", selection: $maintenanceType) {
                ForEach(MaintenanceType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(.navigationLink)
            
            TextField("Description (optional)", text: $description, axis: .vertical)
                .lineLimit(2...4)
        } header: {
            Text("Details")
        }
    }
    
    private var costSection: some View {
        Section {
            HStack {
                Text("Cost")
                Spacer()
                TextField("0", text: $cost)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                Text("USD")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Distance (km)")
                Spacer()
                TextField("0", text: $distance)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
        } header: {
            Text("Cost & Distance")
        }
    }
    
    private var schedulingSection: some View {
        Section {
            Toggle("Schedule for later", isOn: $isScheduled)
            
            if isScheduled {
                DatePicker(
                    "Scheduled Date",
                    selection: $scheduledDate,
                    displayedComponents: .date
                )
            }
            
            TextField("Notes (optional)", text: $notes, axis: .vertical)
                .lineLimit(2...4)
        } header: {
            Text("Scheduling")
        } footer: {
            Text("Scheduled maintenance will send you a reminder notification")
        }
    }
    
    private var bikeSelectionSection: some View {
        Section {
            if bicycles.isEmpty {
                Text("No bikes available")
                    .foregroundColor(.secondary)
            } else {
                Picker("Bike", selection: $selectedBicycle) {
                    Text("None").tag(nil as Bicycle?)
                    ForEach(bicycles) { bike in
                        Text(bike.name).tag(bike as Bicycle?)
                    }
                }
                .pickerStyle(.navigationLink)
                
                if let bike = selectedBicycle, let components = bike.components, !components.isEmpty {
                    Picker("Component", selection: $selectedComponent) {
                        Text("None").tag(nil as Component?)
                        ForEach(components.filter { $0.isActive }) { comp in
                            Text(comp.name).tag(comp as Component?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
            }
        } header: {
            Text("Bike & Component")
        }
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func saveMaintenance() {
        let event = MaintenanceEvent(
            title: title.trimmingCharacters(in: .whitespaces),
            maintenanceType: maintenanceType,
            cost: Double(cost) ?? 0,
            distance: Double(distance) ?? 0
        )
        
        event.maintenanceDescription = description.trimmingCharacters(in: .whitespaces)
        event.notes = notes.trimmingCharacters(in: .whitespaces)
        event.isScheduled = isScheduled
        event.scheduledDate = isScheduled ? scheduledDate : nil
        
        if let bike = selectedBicycle {
            event.bicycle = bike
            bike.totalMaintenanceCost += event.cost
            
            if !isScheduled {
                bike.lastMaintenanceDate = Date()
            }
        }
        
        if let comp = selectedComponent {
            event.component = comp
            comp.lastMaintenanceDate = Date()
        }
        
        modelContext.insert(event)
        dismiss()
    }
}

#Preview {
    AddMaintenanceView()
}
