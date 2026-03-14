import SwiftUI
import SwiftData

struct ComponentListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Component> { $0.isActive }, sort: \Component.name) private var components: [Component]
    
    @State private var selectedComponentType: ComponentType?
    @State private var showingAddComponent = false
    @State private var selectedComponent: Component?
    
    var body: some View {
        NavigationStack {
            Group {
                if components.isEmpty {
                    NoComponentsView(onAddComponent: { showingAddComponent = true })
                } else {
                    componentList
                }
            }
            .navigationTitle("Components")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddComponent = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddComponent) {
                AddComponentView()
            }
            .navigationDestination(item: $selectedComponent) { component in
                ComponentDetailView(component: component)
            }
        }
    }
    
    private var componentList: some View {
        List {
            if !needsAttentionComponents.isEmpty {
                needsAttentionSection
            }
            
            allComponentsSection
        }
        .listStyle(.insetGrouped)
    }
    
    private var needsAttentionComponents: [Component] {
        components.filter { $0.needsAttention }
    }
    
    private var needsAttentionSection: some View {
        Section {
            ForEach(needsAttentionComponents) { component in
                ComponentListRow(component: component)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedComponent = component }
            }
        } header: {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Needs Attention")
            }
        }
    }
    
    private var allComponentsSection: some View {
        Section {
            ForEach(filteredComponents) { component in
                ComponentListRow(component: component)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedComponent = component }
            }
        } header: {
            Text("All Components")
        }
    }
    
    private var filteredComponents: [Component] {
        if let type = selectedComponentType {
            return components.filter { $0.componentType == type }
        }
        return components
    }
}

struct ComponentListRow: View {
    let component: Component
    
    var body: some View {
        HStack(spacing: 12) {
            ComponentProgressRing(component: component)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(component.name)
                        .font(.headline)
                    
                    if component.needsReplacement {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Text(component.componentType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let bike = component.bicycle {
                    Text(bike.name)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(component.usagePercentage))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.color(for: component.healthStatus))
                
                Text(component.remainingDistance.formattedDistance)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ComponentListView()
        .modelContainer(PersistenceController(inMemory: true).container)
}
