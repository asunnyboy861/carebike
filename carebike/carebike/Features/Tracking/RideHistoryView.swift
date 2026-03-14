import SwiftUI
import SwiftData

struct RideHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Ride.startTime, order: .reverse) private var rides: [Ride]
    
    @State private var selectedRide: Ride?
    @State private var timeRange: TimeRange = .allTime
    
    var body: some View {
        NavigationStack {
            Group {
                if rides.isEmpty {
                    NoRidesView()
                } else {
                    rideList
                }
            }
            .navigationTitle("Ride History")
        }
        .sheet(item: $selectedRide) { ride in
            NavigationStack {
                RideDetailView(ride: ride)
            }
        }
    }
    
    private var rideList: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Rides")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(rides.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Total Distance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(totalDistance.formattedDistance)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding(.vertical, 8)
            }
            
            ForEach(groupedRides.keys.sorted().reversed(), id: \.self) { date in
                Section(header: Text(formatSectionHeader(date))) {
                    ForEach(groupedRides[date] ?? []) { ride in
                        RideRow(ride: ride)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedRide = ride
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var totalDistance: Double {
        rides.reduce(0) { $0 + $1.distance }
    }
    
    private var groupedRides: [Date: [Ride]] {
        let calendar = Calendar.current
        return Dictionary(grouping: rides) { ride in
            calendar.startOfDay(for: ride.startTime)
        }
    }
    
    private func formatSectionHeader(_ date: Date) -> String {
        if date.isToday {
            return "Today"
        } else if date.isYesterday {
            return "Yesterday"
        } else {
            return date.formatted(style: .medium)
        }
    }
}

struct RideRow: View {
    let ride: Ride
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bicycle.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                if let bike = ride.bicycle {
                    Text(bike.name)
                        .font(.headline)
                } else {
                    Text("Ride")
                        .font(.headline)
                }
                
                Text(ride.startTime.formatted(dateStyle: .none, timeStyle: .short))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(ride.distance.formattedDistance)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(ride.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RideHistoryView()
        .modelContainer(PersistenceController(inMemory: true).container)
}
