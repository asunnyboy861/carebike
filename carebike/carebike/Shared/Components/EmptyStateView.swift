import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
            }
        }
        .padding(40)
    }
}

struct NoBikesView: View {
    var onAddBike: () -> Void
    
    var body: some View {
        EmptyStateView(
            icon: "bicycle",
            title: "No Bikes Yet",
            subtitle: "Add your first bike to start tracking maintenance and rides.",
            actionTitle: "Add Bike",
            action: onAddBike
        )
    }
}

struct NoComponentsView: View {
    var onAddComponent: () -> Void
    
    var body: some View {
        EmptyStateView(
            icon: "gearshape",
            title: "No Components",
            subtitle: "Track your bike components to monitor wear and get replacement reminders.",
            actionTitle: "Add Component",
            action: onAddComponent
        )
    }
}

struct NoRidesView: View {
    var onStartRide: (() -> Void)?
    
    var body: some View {
        EmptyStateView(
            icon: "bicycle.circle.fill",
            title: "No Rides Recorded",
            subtitle: "Start tracking your rides to see statistics and maintenance insights.",
            actionTitle: onStartRide != nil ? "Start Ride" : nil,
            action: onStartRide
        )
    }
}

struct NoMaintenanceView: View {
    var onAddMaintenance: () -> Void
    
    var body: some View {
        EmptyStateView(
            icon: "wrench.and.screwdriver",
            title: "No Maintenance Records",
            subtitle: "Keep track of all your bike maintenance and service history.",
            actionTitle: "Add Maintenance",
            action: onAddMaintenance
        )
    }
}

#Preview {
    VStack {
        NoBikesView(onAddBike: {})
        NoComponentsView(onAddComponent: {})
        NoRidesView(onStartRide: {})
    }
}
