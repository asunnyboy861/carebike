import SwiftUI
import SwiftData
import Charts

struct MileageChartView: View {
    @Query(sort: \Bicycle.name) private var bicycles: [Bicycle]
    @Query(sort: \Ride.startTime, order: .reverse) private var rides: [Ride]
    
    @State private var selectedBike: Bicycle?
    @State private var timeRange: TimeRange = .lastThreeMonths
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    bikePicker
                    
                    totalDistanceCard
                    
                    distanceByBikeChart
                    
                    weeklyDistanceChart
                }
                .padding()
            }
            .navigationTitle("Mileage")
        }
    }
    
    private var bikePicker: some View {
        Picker("Bike", selection: $selectedBike) {
            Text("All Bikes").tag(nil as Bicycle?)
            ForEach(bicycles) { bike in
                Text(bike.name).tag(bike as Bicycle?)
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    private var totalDistanceCard: some View {
        VStack(spacing: 12) {
            Text("Total Distance")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(filteredRides.reduce(0) { $0 + $1.distance }.formattedDistance)
                .font(.system(size: 36, weight: .bold))
            
            Text("\(filteredRides.count) rides")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var distanceByBikeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distance by Bike")
                .font(.headline)
            
            if bicycles.isEmpty {
                Text("No bikes added")
                    .foregroundColor(.secondary)
            } else {
                Chart(bicycles) { bike in
                    BarMark(
                        x: .value("Distance", bike.totalDistance),
                        y: .value("Bike", bike.name)
                    )
                    .foregroundStyle(Color.theme.color(for: bike.bikeType))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .frame(height: CGFloat(bicycles.count) * 40 + 40)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var weeklyDistanceChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Distance")
                .font(.headline)
            
            let weeklyData = getWeeklyDistance()
            
            if weeklyData.isEmpty {
                Text("No rides recorded")
                    .foregroundColor(.secondary)
            } else {
                Chart(weeklyData, id: \.week) { data in
                    BarMark(
                        x: .value("Week", data.week),
                        y: .value("Distance", data.distance)
                    )
                    .foregroundStyle(Color.theme.primary)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var filteredRides: [Ride] {
        var filtered = rides
        
        if let bike = selectedBike {
            filtered = filtered.filter { $0.bicycle?.id == bike.id }
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        switch timeRange {
        case .lastMonth:
            let startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            filtered = filtered.filter { $0.startTime >= startDate }
        case .lastThreeMonths:
            let startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            filtered = filtered.filter { $0.startTime >= startDate }
        case .lastYear:
            let startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            filtered = filtered.filter { $0.startTime >= startDate }
        case .allTime:
            break
        }
        
        return filtered
    }
    
    private func getWeeklyDistance() -> [(week: String, distance: Double)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let grouped = Dictionary(grouping: filteredRides) { ride -> String in
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: ride.startTime)) ?? ride.startTime
            return formatter.string(from: weekStart)
        }
        
        return grouped.map { (week: $0.key, distance: $0.value.reduce(0) { $0 + $1.distance }) }
            .sorted { $0.week < $1.week }
    }
}

#Preview {
    MileageChartView()
        .modelContainer(PersistenceController(inMemory: true).container)
}
