import Foundation

enum Constants {
    enum App {
        static let name = "BikeCare Pro"
        static let version = "1.0.0"
        static let build = "1"
    }
    
    enum Distance {
        static let chainReplacement = 2000.0
        static let cassetteReplacement = 3000.0
        static let chainringReplacement = 5000.0
        static let brakePadsReplacement = 1500.0
        static let tiresReplacement = 3000.0
        static let cablesReplacement = 10000.0
    }
    
    enum Maintenance {
        static let routineIntervalDays = 30
        static let cleaningIntervalKm = 200.0
        static let inspectionIntervalKm = 500.0
    }
    
    enum Notifications {
        static let maintenanceReminderId = "maintenance_reminder"
        static let componentAlertId = "component_alert"
        static let rideReminderId = "ride_reminder"
    }
    
    enum UI {
        static let defaultPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let largeCornerRadius: CGFloat = 20
    }
    
    enum Animation {
        static let defaultDuration: Double = 0.3
        static let shortDuration: Double = 0.15
        static let longDuration: Double = 0.5
    }
    
    enum Storage {
        static let onboardingCompleted = "onboarding_completed"
        static let preferredDistanceUnit = "preferred_distance_unit"
        static let notificationsEnabled = "notifications_enabled"
        static let lastSyncDate = "last_sync_date"
        static let appGroupIdentifier = "group.com.zzoutuo.carebike"
        static let cloudKitContainerIdentifier = "iCloud.com.zzoutuo.carebike"
    }
}

enum DistanceUnit: String, CaseIterable {
    case kilometers = "km"
    case miles = "mi"
    
    var abbreviation: String {
        rawValue
    }
    
    var fullName: String {
        switch self {
        case .kilometers: return "Kilometers"
        case .miles: return "Miles"
        }
    }
    
    func convert(fromKm km: Double) -> Double {
        switch self {
        case .kilometers: return km
        case .miles: return km * 0.621371
        }
    }
    
    func convert(toKm value: Double) -> Double {
        switch self {
        case .kilometers: return value
        case .miles: return value / 0.621371
        }
    }
}

enum TimeRange: String, CaseIterable {
    case lastMonth = "Last Month"
    case lastThreeMonths = "Last 3 Months"
    case lastYear = "Last Year"
    case allTime = "All Time"
}

enum SpendingTrend {
    case increasing
    case decreasing
    case stable
    
    var icon: String {
        switch self {
        case .increasing: return "arrow.up.circle.fill"
        case .decreasing: return "arrow.down.circle.fill"
        case .stable: return "minus.circle.fill"
        }
    }
    
    var description: String {
        switch self {
        case .increasing: return "Spending is trending up"
        case .decreasing: return "Spending is trending down"
        case .stable: return "Spending is stable"
        }
    }
}
