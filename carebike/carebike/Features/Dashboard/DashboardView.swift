import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bicycle.name) private var bicycles: [Bicycle]
    @Query(filter: #Predicate<Component> { $0.isActive }) private var activeComponents: [Component]
    @Query(filter: #Predicate<MaintenanceEvent> { !$0.isCompleted && $0.isScheduled }) private var pendingMaintenance: [MaintenanceEvent]
    @Query(sort: \Ride.startTime, order: .reverse) private var recentRides: [Ride]
    
    @State private var showingAddBike = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if bicycles.isEmpty {
                        NoBikesView(onAddBike: { showingAddBike = true })
                            .frame(maxHeight: .infinity)
                    } else {
                        summarySection
                        bikesSection
                        componentsNeedingAttentionSection
                        upcomingMaintenanceSection
                        recentRidesSection
                    }
                }
                .padding()
            }
            .refreshable {
                await refreshData()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddBike = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBike) {
                AddBikeView()
            }
        }
    }
    
    private func refreshData() async {
        await PersistenceController.shared.checkMaintenanceNeeds()
        try? modelContext.save()
    }
    
    private var summarySection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                SummaryCard(
                    title: "Total Distance",
                    value: totalDistance.formattedDistance,
                    icon: "bicycle.circle.fill",
                    color: .blue
                )
                
                SummaryCard(
                    title: "Active Bikes",
                    value: "\(bicycles.count)",
                    icon: "bicycle",
                    color: .green
                )
            }
            
            HStack(spacing: 16) {
                SummaryCard(
                    title: "Components",
                    value: "\(activeComponents.count)",
                    icon: "gearshape",
                    color: .orange
                )
                
                SummaryCard(
                    title: "Pending",
                    value: "\(pendingMaintenance.count)",
                    icon: "wrench.and.screwdriver",
                    color: .purple
                )
            }
        }
    }
    
    private var bikesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "My Bikes", icon: "bicycle")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(bicycles) { bike in
                        NavigationLink(value: bike) {
                            BikeCardView(bicycle: bike)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .navigationDestination(for: Bicycle.self) { bike in
            BikeDetailView(bicycle: bike)
        }
    }
    
    private var componentsNeedingAttentionSection: some View {
        let needsAttention = activeComponents.filter { $0.needsAttention }
        
        return Group {
            if !needsAttention.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(
                        title: "Needs Attention",
                        icon: "exclamationmark.triangle",
                        count: needsAttention.count
                    )
                    
                    ForEach(needsAttention.prefix(3)) { component in
                        ComponentAlertRow(component: component)
                    }
                }
            }
        }
    }
    
    private var upcomingMaintenanceSection: some View {
        Group {
            if !pendingMaintenance.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(
                        title: "Upcoming Maintenance",
                        icon: "calendar.badge.clock",
                        count: pendingMaintenance.count
                    )
                    
                    ForEach(pendingMaintenance.prefix(3)) { event in
                        MaintenanceRow(event: event)
                    }
                }
            }
        }
    }
    
    private var recentRidesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recent Rides", icon: "bicycle.circle")
            
            if let lastRide = recentRides.first {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(lastRide.startTime.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                            if let bike = lastRide.bicycle {
                                Text(bike.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(lastRide.distance.formattedDistance)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(lastRide.formattedDuration)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .contentShape(Rectangle())
            } else {
                Text("No rides yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
    }
    
    private var totalDistance: Double {
        bicycles.reduce(0) { $0 + $1.totalDistance }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    var count: Int? = nil
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
            
            if let count = count {
                Text("\(count)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(PersistenceController(inMemory: true).container)
}
