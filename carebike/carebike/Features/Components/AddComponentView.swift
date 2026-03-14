import SwiftUI
import SwiftData

struct AddComponentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var bicycle: Bicycle?
    
    @State private var name = ""
    @State private var componentType: ComponentType = .chain
    @State private var brand = ""
    @State private var model = ""
    @State private var maxDistance: String = ""
    @State private var purchasePrice = ""
    @State private var selectedBicycle: Bicycle?
    
    @Query(sort: \Bicycle.name) private var bicycles: [Bicycle]
    
    init(bicycle: Bicycle? = nil) {
        self.bicycle = bicycle
    }
    
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                detailsSection
                bikeSelectionSection
            }
            .navigationTitle("Add Component")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveComponent()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                selectedBicycle = bicycle ?? bicycles.first
            }
        }
    }
    
    private var basicInfoSection: some View {
        Section {
            TextField("Name", text: $name)
            
            Picker("Type", selection: $componentType) {
                ForEach(ComponentType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: type.icon)
                        Text(type.rawValue)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.navigationLink)
        } header: {
            Text("Basic Info")
        }
    }
    
    private var detailsSection: some View {
        Section(header: Text("Details"), footer: Text("Default max distance for \(componentType.rawValue): \(componentType.defaultMaxDistance.formattedDistance)")) {
            TextField("Brand (optional)", text: $brand)
            
            TextField("Model (optional)", text: $model)
            
            HStack {
                Text("Max Distance (km)")
                Spacer()
                TextField("Auto", text: $maxDistance)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            
            HStack {
                Text("Price")
                Spacer()
                TextField("0", text: $purchasePrice)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                Text("USD")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var bikeSelectionSection: some View {
        Section {
            if bicycles.isEmpty {
                Text("No bikes available. Add a bike first.")
                    .foregroundColor(.secondary)
            } else {
                Picker("Bike", selection: $selectedBicycle) {
                    ForEach(bicycles) { bike in
                        Text(bike.name).tag(bike as Bicycle?)
                    }
                }
                .pickerStyle(.navigationLink)
            }
        } header: {
            Text("Assign to Bike")
        }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && selectedBicycle != nil
    }
    
    private func saveComponent() {
        let component = Component(
            name: name.trimmingCharacters(in: .whitespaces),
            componentType: componentType,
            maxDistance: Double(maxDistance),
            purchasePrice: Double(purchasePrice) ?? 0
        )
        
        component.brand = brand.trimmingCharacters(in: .whitespaces)
        component.model = model.trimmingCharacters(in: .whitespaces)
        
        if let bike = selectedBicycle {
            component.bicycle = bike
        }
        
        modelContext.insert(component)
        dismiss()
    }
}

#Preview {
    AddComponentView()
}
