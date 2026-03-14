import SwiftUI
import SwiftData

struct BikeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bicycle.name) private var bicycles: [Bicycle]
    @State private var showingAddBike = false
    @State private var selectedBike: Bicycle?
    
    var body: some View {
        NavigationStack {
            Group {
                if bicycles.isEmpty {
                    NoBikesView(onAddBike: { showingAddBike = true })
                } else {
                    bikeList
                }
            }
            .navigationTitle("My Bikes")
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
            .navigationDestination(item: $selectedBike) { bike in
                BikeDetailView(bicycle: bike)
            }
        }
    }
    
    private var bikeList: some View {
        List {
            ForEach(bicycles) { bike in
                BikeListRow(bicycle: bike)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedBike = bike
                    }
            }
            .onDelete(perform: deleteBikes)
        }
        .listStyle(.insetGrouped)
    }
    
    private func deleteBikes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(bicycles[index])
            }
        }
    }
}

struct BikeListRow: View {
    let bicycle: Bicycle
    
    var body: some View {
        HStack(spacing: 16) {
            bikeIcon
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bicycle.name)
                    .font(.headline)
                
                Text("\(bicycle.brand) \(bicycle.model) (\(bicycle.year))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label(bicycle.totalDistance.formattedDistance, systemImage: "bicycle.circle.fill")
                    Label("\(bicycle.components?.count ?? 0) components", systemImage: "gearshape")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(
                    status: bicycle.needsMaintenance ? .needsAttention : .good,
                    size: .small
                )
                
                if let days = bicycle.daysSinceLastRide {
                    Text("\(days)d ago")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var bikeIcon: some View {
        ZStack {
            Circle()
                .fill(Color.theme.color(for: bicycle.bikeType).opacity(0.15))
                .frame(width: 50, height: 50)
            
            Image(systemName: bicycle.bikeType.icon)
                .font(.title2)
                .foregroundColor(Color.theme.color(for: bicycle.bikeType))
        }
    }
}

#Preview {
    BikeListView()
        .modelContainer(PersistenceController(inMemory: true).container)
}
