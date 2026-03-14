import SwiftUI
import SwiftData

struct MaintenanceListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MaintenanceEvent.date, order: .reverse) private var maintenanceEvents: [MaintenanceEvent]
    
    @State private var showingAddMaintenance = false
    @State private var filter: MaintenanceFilter = .all
    
    var body: some View {
        NavigationStack {
            Group {
                if maintenanceEvents.isEmpty {
                    NoMaintenanceView(onAddMaintenance: { showingAddMaintenance = true })
                } else {
                    maintenanceList
                }
            }
            .navigationTitle("Maintenance")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddMaintenance = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMaintenance) {
                AddMaintenanceView()
            }
        }
    }
    
    private var maintenanceList: some View {
        List {
            Picker("Filter", selection: $filter) {
                ForEach(MaintenanceFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            ForEach(filteredEvents) { event in
                MaintenanceListRow(event: event)
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var filteredEvents: [MaintenanceEvent] {
        switch filter {
        case .all:
            return maintenanceEvents
        case .scheduled:
            return maintenanceEvents.filter { $0.isScheduled && !$0.isCompleted }
        case .completed:
            return maintenanceEvents.filter { $0.isCompleted }
        case .overdue:
            return maintenanceEvents.filter { event in
                guard event.isScheduled, !event.isCompleted, let date = event.scheduledDate else { return false }
                return date < Date()
            }
        }
    }
}

enum MaintenanceFilter: String, CaseIterable {
    case all = "All"
    case scheduled = "Scheduled"
    case completed = "Completed"
    case overdue = "Overdue"
}

struct MaintenanceListRow: View {
    let event: MaintenanceEvent
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.maintenanceType.icon)
                .font(.title2)
                .foregroundColor(event.isCompleted ? .green : .purple)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.title)
                        .font(.headline)
                        .strikethrough(event.isCompleted)
                    
                    if event.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                HStack(spacing: 8) {
                    if let bike = event.bicycle {
                        Label(bike.name, systemImage: "bicycle")
                    }
                    
                    if event.isScheduled, let scheduledDate = event.scheduledDate {
                        Label(scheduledDate.shortRelativeString, systemImage: "calendar")
                    } else {
                        Label(event.date.shortRelativeString, systemImage: "clock")
                    }
                }
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
        .padding(.vertical, 4)
    }
}

#Preview {
    MaintenanceListView()
        .modelContainer(PersistenceController(inMemory: true).container)
}
