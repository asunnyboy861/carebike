import SwiftUI
import SwiftData

struct BikeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var bicycle: Bicycle
    @State private var showingEditBike = false
    @State private var showingAddComponent = false
    @State private var showingAddMaintenance = false
    
    var body: some View {
        List {
            bikeInfoSection
            statsSection
            componentsSection
            recentMaintenanceSection
            costSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(bicycle.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { showingEditBike = true }) {
                        Label("Edit Bike", systemImage: "pencil")
                    }
                    
                    Button(action: { showingAddComponent = true }) {
                        Label("Add Component", systemImage: "plus.circle")
                    }
                    
                    Button(action: { showingAddMaintenance = true }) {
                        Label("Log Maintenance", systemImage: "wrench.and.screwdriver")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: deleteBike) {
                        Label("Delete Bike", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditBike) {
            EditBikeView(bicycle: bicycle)
        }
        .sheet(isPresented: $showingAddComponent) {
            AddComponentView(bicycle: bicycle)
        }
        .sheet(isPresented: $showingAddMaintenance) {
            AddMaintenanceView(bicycle: bicycle)
        }
    }
    
    private var bikeInfoSection: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.theme.color(for: bicycle.bikeType).opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: bicycle.bikeType.icon)
                            .font(.system(size: 36))
                            .foregroundColor(Color.theme.color(for: bicycle.bikeType))
                    }
                    
                    Text(bicycle.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(bicycle.brand) \(bicycle.model)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(bicycle.bikeType.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.theme.color(for: bicycle.bikeType).opacity(0.15))
                        .foregroundColor(Color.theme.color(for: bicycle.bikeType))
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    private var statsSection: some View {
        Section {
            LabeledContent("Total Distance", value: bicycle.totalDistance.formattedDistance)
            
            LabeledContent("Components", value: "\(bicycle.components?.count ?? 0)")
            
            if let lastRide = bicycle.lastRideDate {
                LabeledContent("Last Ride", value: lastRide.shortRelativeString)
            }
            
            if let lastMaintenance = bicycle.lastMaintenanceDate {
                LabeledContent("Last Maintenance", value: lastMaintenance.shortRelativeString)
            }
            
            LabeledContent("Purchase Date", value: bicycle.purchaseDate.formatted())
            
            if bicycle.purchasePrice > 0 {
                LabeledContent("Purchase Price", value: bicycle.purchasePrice.formattedCurrency)
            }
        } header: {
            Text("Statistics")
        }
    }
    
    private var componentsSection: some View {
        Section {
            if let components = bicycle.components, !components.isEmpty {
                ForEach(components.filter { $0.isActive }) { component in
                    NavigationLink(value: component) {
                        ComponentRow(component: component)
                    }
                }
            } else {
                Text("No components added")
                    .foregroundColor(.secondary)
            }
        } header: {
            HStack {
                Text("Components")
                Spacer()
                Button(action: { showingAddComponent = true }) {
                    Image(systemName: "plus.circle")
                }
            }
        }
    }
    
    private var recentMaintenanceSection: some View {
        Section {
            let recentEvents = (bicycle.maintenanceEvents ?? [])
                .sorted { $0.date > $1.date }
                .prefix(5)
            
            if recentEvents.isEmpty {
                Text("No maintenance recorded")
                    .foregroundColor(.secondary)
            } else {
                ForEach(recentEvents) { event in
                    MaintenanceEventRow(event: event)
                }
            }
        } header: {
            HStack {
                Text("Recent Maintenance")
                Spacer()
                Button(action: { showingAddMaintenance = true }) {
                    Image(systemName: "plus.circle")
                }
            }
        }
    }
    
    private var costSection: some View {
        Section {
            LabeledContent("Total Maintenance Cost") {
                Text(bicycle.totalMaintenanceCost.formattedCurrency)
                    .foregroundColor(.secondary)
            }
            
            if bicycle.purchasePrice > 0 {
                let totalInvestment = bicycle.purchasePrice + bicycle.totalMaintenanceCost
                LabeledContent("Total Investment") {
                    Text(totalInvestment.formattedCurrency)
                        .fontWeight(.semibold)
                }
            }
        } header: {
            Text("Costs")
        }
    }
    
    private func deleteBike() {
        modelContext.delete(bicycle)
        dismiss()
    }
}

struct ComponentRow: View {
    let component: Component
    
    var body: some View {
        HStack(spacing: 12) {
            ProgressRing(
                progress: component.usagePercentage / 100,
                lineWidth: 3,
                size: 36,
                showPercentage: false,
                color: Color.theme.color(for: component.healthStatus)
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(component.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(component.componentType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(component.usagePercentage))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.color(for: component.healthStatus))
                
                Text(component.remainingDistance.formattedDistance)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MaintenanceEventRow: View {
    let event: MaintenanceEvent
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.maintenanceType.icon)
                .foregroundColor(.purple)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline)
                
                Text(event.date.shortRelativeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if event.cost > 0 {
                Text(event.cost.formattedCurrency)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        BikeDetailView(bicycle: {
            let bike = Bicycle(name: "My Road Bike", brand: "Specialized", model: "Allez", year: 2024, bikeType: .road)
            bike.totalDistance = 1234.5
            return bike
        }())
    }
    .modelContainer(PersistenceController(inMemory: true).container)
}
