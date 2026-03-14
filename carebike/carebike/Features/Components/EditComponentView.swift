import SwiftUI
import SwiftData

struct EditComponentView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var component: Component
    
    @State private var name: String
    @State private var componentType: ComponentType
    @State private var brand: String
    @State private var model: String
    @State private var maxDistance: String
    @State private var purchasePrice: String
    @State private var currentDistance: String
    @State private var isActive: Bool
    
    init(component: Component) {
        self.component = component
        _name = State(initialValue: component.name)
        _componentType = State(initialValue: component.componentType)
        _brand = State(initialValue: component.brand ?? "")
        _model = State(initialValue: component.model ?? "")
        _maxDistance = State(initialValue: String(component.maxDistance))
        _purchasePrice = State(initialValue: String(component.purchasePrice))
        _currentDistance = State(initialValue: String(component.currentDistance))
        _isActive = State(initialValue: component.isActive)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                detailsSection
                usageSection
            }
            .navigationTitle("Edit Component")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var basicInfoSection: some View {
        Section {
            TextField("Name", text: $name)
            
            Picker("Type", selection: $componentType) {
                ForEach(ComponentType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.navigationLink)
        } header: {
            Text("Basic Info")
        }
    }
    
    private var detailsSection: some View {
        Section {
            TextField("Brand", text: $brand)
            TextField("Model", text: $model)
            
            HStack {
                Text("Max Distance (km)")
                Spacer()
                TextField("", text: $maxDistance)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            
            HStack {
                Text("Price")
                Spacer()
                TextField("", text: $purchasePrice)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                Text("USD")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Details")
        }
    }
    
    private var usageSection: some View {
        Section(header: Text("Usage"), footer: Text("Manually adjust distance if needed. Usually updated automatically from rides.")) {
            HStack {
                Text("Current Distance (km)")
                Spacer()
                TextField("", text: $currentDistance)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            
            Toggle("Active", isOn: $isActive)
        }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func saveChanges() {
        component.name = name.trimmingCharacters(in: .whitespaces)
        component.componentType = componentType
        component.brand = brand.trimmingCharacters(in: .whitespaces)
        component.model = model.trimmingCharacters(in: .whitespaces)
        component.maxDistance = Double(maxDistance) ?? component.maxDistance
        component.purchasePrice = Double(purchasePrice) ?? component.purchasePrice
        component.currentDistance = Double(currentDistance) ?? component.currentDistance
        component.isActive = isActive
        component.updateHealthStatus()
        
        dismiss()
    }
}

#Preview {
    EditComponentView(component: Component(name: "Chain", componentType: .chain))
}
