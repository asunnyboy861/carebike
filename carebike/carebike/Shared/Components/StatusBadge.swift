import SwiftUI

struct StatusBadge: View {
    let status: BadgeStatus
    var size: BadgeSize = .medium
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.system(size: iconSize))
            Text(status.title)
                .font(.system(size: textSize, weight: .medium))
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(status.color.opacity(0.15))
        .foregroundColor(status.color)
        .cornerRadius(cornerRadius)
    }
    
    private var iconSize: CGFloat {
        switch size {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        }
    }
    
    private var textSize: CGFloat {
        switch size {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small: return 6
        case .medium: return 8
        case .large: return 10
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .small: return 3
        case .medium: return 4
        case .large: return 6
        }
    }
    
    private var cornerRadius: CGFloat {
        switch size {
        case .small: return 4
        case .medium: return 6
        case .large: return 8
        }
    }
}

enum BadgeSize {
    case small, medium, large
}

enum BadgeStatus {
    case excellent
    case good
    case fair
    case poor
    case critical
    case needsAttention
    case scheduled
    case completed
    case active
    case inactive
    
    var title: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        case .critical: return "Critical"
        case .needsAttention: return "Needs Attention"
        case .scheduled: return "Scheduled"
        case .completed: return "Completed"
        case .active: return "Active"
        case .inactive: return "Inactive"
        }
    }
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .yellow
        case .poor: return .orange
        case .critical: return .red
        case .needsAttention: return .orange
        case .scheduled: return .purple
        case .completed: return .green
        case .active: return .green
        case .inactive: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .excellent: return "checkmark.circle.fill"
        case .good: return "checkmark.circle"
        case .fair: return "exclamationmark.circle"
        case .poor: return "exclamationmark.triangle"
        case .critical: return "xmark.octagon.fill"
        case .needsAttention: return "exclamationmark.circle.fill"
        case .scheduled: return "calendar"
        case .completed: return "checkmark.circle.fill"
        case .active: return "circle.fill"
        case .inactive: return "circle"
        }
    }
    
    static func from(health: ComponentHealth) -> BadgeStatus {
        switch health {
        case .excellent: return .excellent
        case .good: return .good
        case .fair: return .fair
        case .poor: return .poor
        case .replaceNow: return .critical
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        StatusBadge(status: .excellent)
        StatusBadge(status: .good)
        StatusBadge(status: .fair)
        StatusBadge(status: .poor)
        StatusBadge(status: .critical)
        StatusBadge(status: .needsAttention)
        StatusBadge(status: .scheduled)
        StatusBadge(status: .completed)
    }
    .padding()
}
