import SwiftUI
import SwiftData
import Charts

struct MonthlySpending: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}

struct CostAnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Bicycle.name) private var bicycles: [Bicycle]
    
    @State private var selectedTimeRange: TimeRange = .allTime
    @State private var selectedBike: Bicycle?
    
    @State private var totalSpending: Double = 0
    @State private var spendingByCategory: [CostType: Double] = [:]
    @State private var spendingByBike: [Bicycle: Double] = [:]
    @State private var monthlyTrend: [MonthlySpending] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.UI.defaultPadding) {
                    timeRangePicker
                    totalSpendingCard
                    spendingByCategorySection
                    spendingByBikeSection
                    monthlyTrendSection
                }
                .padding()
            }
            .navigationTitle("Cost Analytics")
        }
        .onAppear {
            Task {
                await analyzeSpending()
            }
        }
        .onChange(of: selectedTimeRange) { _, _ in
            Task {
                await analyzeSpending()
            }
        }
        .onChange(of: selectedBike) { _, _ in
            Task {
                await analyzeSpending()
            }
        }
    }
    
    private func analyzeSpending() async {
        let analyzer = CostAnalyzer(modelContext: modelContext)
        await analyzer.analyzeSpending(for: selectedBike, timeRange: selectedTimeRange)
        
        totalSpending = analyzer.totalSpending
        spendingByCategory = analyzer.categorySpending
        
        // Convert bikeSpending [UUID: Double] to [Bicycle: Double]
        var bikeSpendingMap: [Bicycle: Double] = [:]
        for (bikeId, amount) in analyzer.bikeSpending {
            if let bike = bicycles.first(where: { $0.id == bikeId }) {
                bikeSpendingMap[bike] = amount
            }
        }
        spendingByBike = bikeSpendingMap
        
        // Convert monthlySpending [String: Double] to [MonthlySpending]
        monthlyTrend = analyzer.monthlySpending.map { month, amount in
            MonthlySpending(month: month, amount: amount)
        }
    }
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var totalSpendingCard: some View {
        VStack(spacing: 12) {
            Text("Total Spending")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(totalSpending.formattedCurrency)
                .font(.system(size: 36, weight: .bold))
            
            let trend = getSpendingTrend()
            HStack {
                Image(systemName: trend.icon)
                Text(trend.description)
            }
            .font(.caption)
            .foregroundColor(trend == .increasing ? .red : .green)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(Constants.UI.cornerRadius)
    }
    
    private func getSpendingTrend() -> SpendingTrend {
        let sortedMonths = monthlyTrend.map { $0.month }.sorted()
        
        guard sortedMonths.count >= 2 else { return .stable }
        
        let recentMonths = sortedMonths.suffix(3)
        let previousMonths = sortedMonths.dropLast(3).suffix(3)
        
        let recentAverage = recentMonths.compactMap { month in
            monthlyTrend.first { $0.month == month }?.amount
        }.reduce(0, +) / Double(max(recentMonths.count, 1))
        
        let previousAverage = previousMonths.compactMap { month in
            monthlyTrend.first { $0.month == month }?.amount
        }.reduce(0, +) / Double(max(previousMonths.count, 1))
        
        let change = (recentAverage - previousAverage) / max(previousAverage, 1) * 100
        
        if change > 20 { return .increasing }
        if change < -20 { return .decreasing }
        return .stable
    }
    
    private var spendingByCategorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)
            
            if spendingByCategory.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
            } else {
                let sortedItems = spendingByCategory.sorted(by: { $0.value > $1.value })
                Chart(sortedItems, id: \.key) { item in
                    BarMark(
                        x: .value("Amount", item.value),
                        y: .value("Category", item.key.rawValue)
                    )
                    .foregroundStyle(Color.theme.primary)
                    .annotation(position: .trailing) {
                        Text(item.value.formattedCurrency)
                            .font(.caption)
                    }
                }
                .chartXAxis(.hidden)
                .frame(height: CGFloat(spendingByCategory.count) * 40)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(Constants.UI.cornerRadius)
    }
    
    private var spendingByBikeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Bike")
                .font(.headline)
            
            if bicycles.isEmpty {
                Text("No bikes added")
                    .foregroundColor(.secondary)
            } else {
                ForEach(bicycles) { bike in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(bike.name)
                                .font(.subheadline)
                            Text("\(bike.totalDistance.formattedDistance) total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(bike.totalMaintenanceCost.formattedCurrency)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("\(getCostPerKilometer(for: bike).formattedCurrency)/km")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if bike.id != bicycles.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(Constants.UI.cornerRadius)
    }
    
    private func getCostPerKilometer(for bicycle: Bicycle) -> Double {
        guard bicycle.totalDistance > 0 else { return 0 }
        let totalCost = spendingByBike[bicycle, default: 0]
        return totalCost / bicycle.totalDistance
    }
    
    private var monthlyTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Trend")
                .font(.headline)
            
            if monthlyTrend.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
            } else {
                let sortedTrend = monthlyTrend.sorted(by: { $0.month < $1.month })
                Chart(sortedTrend, id: \.month) { item in
                    LineMark(
                        x: .value("Month", item.month),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(Color.theme.primary)
                    
                    PointMark(
                        x: .value("Month", item.month),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(Color.theme.primary)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(Constants.UI.cornerRadius)
    }
}

#Preview {
    CostAnalyticsView()
        .modelContainer(PersistenceController(inMemory: true).container)
}
