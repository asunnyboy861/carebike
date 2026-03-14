import SwiftUI
import SwiftData

@main
struct carebikeApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    @AppStorage(Constants.Storage.onboardingCompleted) private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .modelContainer(persistenceController.container)
                    .environmentObject(persistenceController)
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        Task {
                            await persistenceController.checkMaintenanceNeeds()
                        }
                    }
            } else {
                OnboardingView()
            }
        }
    }
}
