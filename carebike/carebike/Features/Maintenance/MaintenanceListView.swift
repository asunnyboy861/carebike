import SwiftUI
import SwiftData

struct MaintenanceListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MaintenanceEvent.date, order: .reverse) private var maintenanceEvents: [MaintenanceEvent]
    
    @State private var showingAddMaintenance = false
    @State private var showingEditMaintenance = false
    @State private var selectedEvent: MaintenanceEvent?
    @State private var filter: MaintenanceFilter = .all
    @State private var showingDeleteConfirmation = false
    @State private var eventToDelete: MaintenanceEvent?
    
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
            .sheet(isPresented: $showingEditMaintenance) {
                if let event = selectedEvent {
                    EditMaintenanceView(event: event)
                }
            }
            .alert("Delete Maintenance Record?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let event = eventToDelete {
                        deleteEvent(event)
                    }
                }
            } message: {
                Text("This action cannot be undone. The maintenance record will be permanently deleted.")
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedEvent = event
                        showingEditMaintenance = true
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            eventToDelete = event
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            selectedEvent = event
                            showingEditMaintenance = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        if !event.isCompleted {
                            Button {
                                markAsCompleted(event)
                            } label: {
                                Label("Complete", systemImage: "checkmark")
                            }
                            .tint(.green)
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func markAsCompleted(_ event: MaintenanceEvent) {
        Task { @MainActor in
            do {
                event.isCompleted = true
                event.date = Date()
                
                if let bike = event.bicycle {
                    bike.lastMaintenanceDate = Date()
                }
                if let comp = event.component {
                    comp.lastMaintenanceDate = Date()
                }
                
                try modelContext.save()
            } catch {
                print("Error marking maintenance as completed: \(error)")
            }
        }
    }
    
    private func deleteEvent(_ event: MaintenanceEvent) {
        Task { @MainActor in
            do {
                // 从自行车总成本中减去
                if let bike = event.bicycle {
                    bike.totalMaintenanceCost -= event.cost
                }
                
                modelContext.delete(event)
                try modelContext.save()
            } catch {
                print("Error deleting maintenance event: \(error)")
            }
        }
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
