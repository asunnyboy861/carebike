import Foundation
import SwiftData

@MainActor
class ComponentViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedType: ComponentType?
    @Published var showOnlyNeedsAttention = false
    
    func filterComponents(_ components: [Component]) -> [Component] {
        var filtered = components.filter { $0.isActive }
        
        if showOnlyNeedsAttention {
            filtered = filtered.filter { $0.needsAttention }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { component in
                component.name.localizedCaseInsensitiveContains(searchText) ||
                component.componentType.rawValue.localizedCaseInsensitiveContains(searchText) ||
                (component.brand?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if let type = selectedType {
            filtered = filtered.filter { $0.componentType == type }
        }
        
        return filtered.sorted { $0.usagePercentage > $1.usagePercentage }
    }
    
    func getComponentsByType(_ components: [Component]) -> [ComponentType: [Component]] {
        Dictionary(grouping: components.filter { $0.isActive }) { $0.componentType }
    }
    
    func getComponentsNeedingReplacement(_ components: [Component]) -> [Component] {
        components.filter { $0.needsReplacement }
    }
    
    func getComponentsNeedingAttention(_ components: [Component]) -> [Component] {
        components.filter { $0.needsAttention }
    }
    
    func updateComponentDistance(_ component: Component, additionalDistance: Double) {
        component.currentDistance += additionalDistance
        component.updateHealthStatus()
    }
    
    func getTotalComponentsValue(_ components: [Component]) -> Double {
        components.filter { $0.isActive }.reduce(0) { $0 + $1.purchasePrice }
    }
}
