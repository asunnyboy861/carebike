import Foundation
import UserNotifications
import UIKit

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationEnabled = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            let granted = try await notificationCenter.requestAuthorization(options: options)
            isNotificationEnabled = granted
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    func scheduleMaintenanceReminder(
        id: String,
        title: String,
        body: String,
        date: Date,
        repeats: Bool = false
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: repeats
        )
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await notificationCenter.add(request)
    }
    
    func scheduleDistanceBasedReminder(
        id: String,
        title: String,
        body: String,
        interval: TimeInterval = 60
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        try await notificationCenter.add(request)
    }
    
    func cancelNotification(id: String) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func cancelAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        let requests = await notificationCenter.pendingNotificationRequests()
        pendingNotifications = requests
        return requests
    }
    
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

enum NotificationIdentifier {
    static let maintenancePrefix = "maintenance_"
    static let componentPrefix = "component_"
    static let ridePrefix = "ride_"
    
    static func maintenance(id: UUID) -> String {
        "\(maintenancePrefix)\(id.uuidString)"
    }
    
    static func component(id: UUID) -> String {
        "\(componentPrefix)\(id.uuidString)"
    }
    
    static func ride(id: UUID) -> String {
        "\(ridePrefix)\(id.uuidString)"
    }
}
