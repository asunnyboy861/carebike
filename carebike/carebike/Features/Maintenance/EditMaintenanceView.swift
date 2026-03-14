import SwiftUI
import SwiftData

struct EditMaintenanceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var event: MaintenanceEvent
    
    @State private var title: String
    @State private var maintenanceType: MaintenanceType
    @State private var description: String
    @State private var cost: String
    @State private var distance: String
    @State private var isScheduled: Bool
    @State private var scheduledDate: Date
    @State private var isCompleted: Bool
    @State private var notes: String
    @State private var selectedBicycle: Bicycle?
    @State private var selectedComponent: Component?
    
    @Query(sort: \Bicycle.name) private var bicycles: [Bicycle]
    
    init(event: MaintenanceEvent) {
        self.event = event
        _title = State(initialValue: event.title)
        _maintenanceType = State(initialValue: event.maintenanceType)
        _description = State(initialValue: event.maintenanceDescription ?? "")
        _cost = State(initialValue: String(event.cost))
        _distance = State(initialValue: String(event.distance))
        _isScheduled = State(initialValue: event.isScheduled)
        _scheduledDate = State(initialValue: event.scheduledDate ?? Date())
        _isCompleted = State(initialValue: event.isCompleted)
        _notes = State(initialValue: event.notes ?? "")
        _selectedBicycle = State(initialValue: event.bicycle)
        _selectedComponent = State(initialValue: event.component)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                statusSection
                costSection
                schedulingSection
                bikeSelectionSection
            }
            .navigationTitle("Edit Maintenance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                // 只在首次加载时初始化，避免从Picker返回时重置数据
                if selectedBicycle == nil {
                    selectedBicycle = event.bicycle ?? bicycles.first
                }
                if selectedComponent == nil {
                    selectedComponent = event.component
                }
            }
            .onChange(of: selectedBicycle) { oldBike, newBike in
                // 当切换自行车时，验证当前选中的组件是否属于新自行车
                if let comp = selectedComponent, let bike = newBike {
                    let isComponentValid = bike.components?.contains(where: { $0.id == comp.id }) ?? false
                    if !isComponentValid {
                        // 如果组件不属于新自行车，重置组件选择
                        selectedComponent = nil
                    }
                } else if newBike == nil {
                    // 如果没有选择自行车，清空组件选择
                    selectedComponent = nil
                }
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
    
    private var statusSection: some View {
        Section {
            Toggle("Completed", isOn: $isCompleted)
            
            if isCompleted {
                HStack {
                    Text("Completion Date")
                    Spacer()
                    Text(event.date.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("Status")
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
            Toggle("Scheduled maintenance", isOn: $isScheduled)
            
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
                
                if let bike = selectedBicycle {
                    let activeComponents = getActiveComponents(for: bike)
                    if !activeComponents.isEmpty {
                        Picker("Component", selection: $selectedComponent) {
                            Text("None").tag(nil as Component?)
                            ForEach(activeComponents, id: \.id) { comp in
                                Text(comp.name).tag(Optional(comp))
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                }
            }
        } header: {
            Text("Bike & Component")
        }
    }
    
    private func getActiveComponents(for bike: Bicycle) -> [Component] {
        guard let components = bike.components else { return [] }
        return components.filter { $0.isActive }.sorted { $0.name < $1.name }
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func saveChanges() {
        Task { @MainActor in
            do {
                // 计算成本差异，更新自行车总维护成本
                let oldCost = event.cost
                let newCost = Double(cost) ?? 0
                let costDifference = newCost - oldCost
                
                // 更新事件属性
                event.title = title.trimmingCharacters(in: .whitespaces)
                event.maintenanceType = maintenanceType
                event.maintenanceDescription = description.trimmingCharacters(in: .whitespaces)
                event.cost = newCost
                event.distance = Double(distance) ?? 0
                event.isScheduled = isScheduled
                event.scheduledDate = isScheduled ? scheduledDate : nil
                event.isCompleted = isCompleted
                event.notes = notes.trimmingCharacters(in: .whitespaces)
                
                // 如果标记为完成且之前未完成，更新完成日期
                if isCompleted && !event.isCompleted {
                    event.date = Date()
                }
                
                // 更新自行车关联
                if let bike = selectedBicycle {
                    // 如果自行车改变了，调整成本
                    if event.bicycle?.id != bike.id {
                        // 从旧自行车减去成本
                        if let oldBike = event.bicycle {
                            oldBike.totalMaintenanceCost -= oldCost
                        }
                        // 添加到新自行车
                        bike.totalMaintenanceCost += newCost
                        event.bicycle = bike
                    } else {
                        // 同一自行车，只更新成本差异
                        bike.totalMaintenanceCost += costDifference
                    }
                    
                    if !isScheduled {
                        bike.lastMaintenanceDate = Date()
                    }
                } else {
                    // 如果没有选择自行车，从旧自行车减去成本
                    if let oldBike = event.bicycle {
                        oldBike.totalMaintenanceCost -= oldCost
                        event.bicycle = nil
                    }
                }
                
                // 更新组件关联
                if let comp = selectedComponent {
                    event.component = comp
                    if !isScheduled {
                        comp.lastMaintenanceDate = Date()
                    }
                } else {
                    event.component = nil
                }
                
                // 显式保存上下文
                try modelContext.save()
                
                dismiss()
            } catch {
                print("Error saving maintenance changes: \(error)")
            }
        }
    }
}

#Preview {
    EditMaintenanceView(event: MaintenanceEvent(title: "Test", maintenanceType: .routine))
        .modelContainer(PersistenceController(inMemory: true).container)
}
