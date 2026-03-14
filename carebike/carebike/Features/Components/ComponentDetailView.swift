import SwiftUI
import SwiftData

struct ComponentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var component: Component
    @State private var showingEditComponent = false
    @State private var showingAddMaintenance = false
    
    var body: some View {
        List {
            overviewSection
            usageSection
            maintenanceTipsSection
            historySection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(component.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { showingEditComponent = true }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(action: { showingAddMaintenance = true }) {
                        Label("Log Maintenance", systemImage: "wrench.and.screwdriver")
                    }
                    
                    Button(action: markAsReplaced) {
                        Label("Mark as Replaced", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: deleteComponent) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditComponent) {
            EditComponentView(component: component)
        }
        .sheet(isPresented: $showingAddMaintenance) {
            if let bike = component.bicycle {
                AddMaintenanceView(bicycle: bike, component: component)
            }
        }
    }
    
    private var overviewSection: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    ComponentProgressRing(component: component)
                    
                    Text(component.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    StatusBadge(status: BadgeStatus.from(health: component.healthStatus))
                    
                    if let brand = component.brand, let model = component.model {
                        Text("\(brand) \(model)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    private var usageSection: some View {
        Section {
            LabeledContent("Type", value: component.componentType.rawValue)
            
            LabeledContent("Current Distance") {
                Text(component.currentDistance.formattedDistance)
            }
            
            LabeledContent("Max Distance") {
                Text(component.maxDistance.formattedDistance)
            }
            
            LabeledContent("Remaining") {
                Text(component.remainingDistance.formattedDistance)
                    .foregroundColor(component.remainingDistance < 500 ? .orange : .primary)
            }
            
            LabeledContent("Usage") {
                Text(component.usagePercentage.formattedPercent)
                    .foregroundColor(Color.theme.color(for: component.healthStatus))
            }
            
            LabeledContent("Installed") {
                Text(component.installDate.formatted())
            }
            
            if let bike = component.bicycle {
                LabeledContent("Bike") {
                    Text(bike.name)
                }
            }
            
            if component.purchasePrice > 0 {
                LabeledContent("Cost", value: component.purchasePrice.formattedCurrency)
            }
        } header: {
            Text("Usage")
        }
    }
    
    private var maintenanceTipsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(component.componentType.maintenanceTips)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Maintenance Tips")
        }
    }
    
    private var historySection: some View {
        Section {
            if let lastMaintenance = component.lastMaintenanceDate {
                LabeledContent("Last Service", value: lastMaintenance.shortRelativeString)
            } else {
                Text("No maintenance recorded")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Maintenance History")
        }
    }
    
    private func markAsReplaced() {
        let newComponent = Component(
            name: component.name,
            componentType: component.componentType,
            purchasePrice: component.purchasePrice
        )
        
        if let bike = component.bicycle {
            newComponent.bicycle = bike
        }
        
        component.isActive = false
        dismiss()
    }
    
    private func deleteComponent() {
        modelContext.delete(component)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ComponentDetailView(component: {
            let comp = Component(name: "Chain", componentType: .chain)
            comp.currentDistance = 1800
            comp.updateHealthStatus()
            return comp
        }())
    }
}
