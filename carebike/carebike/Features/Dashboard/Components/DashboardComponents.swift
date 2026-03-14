import SwiftUI

struct BikeCardView: View {
    let bicycle: Bicycle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: bicycle.bikeType.icon)
                    .font(.title2)
                    .foregroundColor(Color.theme.color(for: bicycle.bikeType))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(bicycle.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("\(bicycle.brand) \(bicycle.model)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bicycle.totalDistance.formattedDistance)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Total Distance")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if bicycle.needsMaintenance {
                    StatusBadge(status: .needsAttention, size: .small)
                } else {
                    StatusBadge(status: .good, size: .small)
                }
            }
            
            if let daysSince = bicycle.daysSinceLastRide {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("Last ride \(daysSince) days ago")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ComponentAlertRow: View {
    let component: Component
    
    var body: some View {
        HStack(spacing: 12) {
            ProgressRing(
                progress: component.usagePercentage / 100,
                lineWidth: 4,
                size: 44,
                showPercentage: false,
                color: Color.theme.color(for: component.healthStatus)
            )
            .overlay(
                Image(systemName: component.componentType.icon)
                    .font(.system(size: 12))
                    .foregroundColor(Color.theme.color(for: component.healthStatus))
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(component.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let bike = component.bicycle {
                    Text(bike.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(component.usagePercentage))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.color(for: component.healthStatus))
                
                Text(component.healthStatus.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MaintenanceRow: View {
    let event: MaintenanceEvent
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.maintenanceType.icon)
                .font(.title3)
                .foregroundColor(.purple)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let scheduledDate = event.scheduledDate {
                    Text(scheduledDate.shortRelativeString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if event.cost > 0 {
                Text(event.cost.formattedCurrency)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 20) {
        BikeCardView(bicycle: {
            let bike = Bicycle(name: "My Road Bike", brand: "Specialized", model: "Allez", year: 2024, bikeType: .road)
            bike.totalDistance = 1234.5
            return bike
        }())
        
        ComponentAlertRow(component: {
            let comp = Component(name: "Chain", componentType: .chain)
            comp.currentDistance = 1800
            comp.updateHealthStatus()
            return comp
        }())
        
        MaintenanceRow(event: {
            let event = MaintenanceEvent(title: "Chain Replacement", maintenanceType: .replacement)
            event.scheduledDate = Date().adding(days: 3)
            return event
        }())
    }
    .padding()
}
