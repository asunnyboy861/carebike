import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var persistenceController: PersistenceController
    @State private var selectedTab: Tab = .dashboard
    
    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case bikes = "Bikes"
        case tracking = "Track"
        case maintenance = "Maintenance"
        case more = "More"
        
        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .bikes: return "bicycle"
            case .tracking: return "bicycle.circle.fill"
            case .maintenance: return "wrench.and.screwdriver.fill"
            case .more: return "ellipsis.circle.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(Tab.dashboard.rawValue, systemImage: Tab.dashboard.icon)
                }
                .tag(Tab.dashboard)
            
            BikeListView()
                .tabItem {
                    Label(Tab.bikes.rawValue, systemImage: Tab.bikes.icon)
                }
                .tag(Tab.bikes)
            
            StartRideView()
                .tabItem {
                    Label(Tab.tracking.rawValue, systemImage: Tab.tracking.icon)
                }
                .tag(Tab.tracking)
            
            MaintenanceListView()
                .tabItem {
                    Label(Tab.maintenance.rawValue, systemImage: Tab.maintenance.icon)
                }
                .tag(Tab.maintenance)
            
            MoreView()
                .tabItem {
                    Label(Tab.more.rawValue, systemImage: Tab.more.icon)
                }
                .tag(Tab.more)
        }
        .tint(.blue)
        .onAppear {
            Task {
                await persistenceController.checkMaintenanceNeeds()
            }
        }
    }
}



struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: ComponentListView()) {
                        Label("Components", systemImage: "gearshape.fill")
                    }
                    
                    NavigationLink(destination: CostAnalyticsView()) {
                        Label("Cost Analytics", systemImage: "chart.bar.fill")
                    }
                    
                    NavigationLink(destination: MileageChartView()) {
                        Label("Mileage Stats", systemImage: "map.fill")
                    }
                    
                    NavigationLink(destination: KnowledgeBaseView()) {
                        Label("Knowledge Base", systemImage: "book.fill")
                    }
                }
                
                Section {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("More")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PersistenceController(inMemory: true).container)
}
