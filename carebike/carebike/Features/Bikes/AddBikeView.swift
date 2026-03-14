import SwiftUI
import SwiftData

struct AddBikeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var brand = ""
    @State private var model = ""
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var bikeType: BikeType = .road
    @State private var purchasePrice = ""
    @State private var addDefaultComponents = true
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, brand, model, price
    }
    
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                bikeTypeSection
                purchaseSection
                componentsOptionSection
            }
            .navigationTitle("Add Bike")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveBike()
                    }
                    .disabled(!isValid)
                }
            }
            .focused($focusedField, equals: .name)
        }
    }
    
    private var basicInfoSection: some View {
        Section {
            TextField("Name", text: $name)
                .focused($focusedField, equals: .name)
            
            TextField("Brand", text: $brand)
                .focused($focusedField, equals: .brand)
            
            TextField("Model", text: $model)
                .focused($focusedField, equals: .model)
            
            Stepper("Year: \(year)", value: $year, in: 1990...Calendar.current.component(.year, from: Date()) + 1)
        } header: {
            Text("Basic Info")
        }
    }
    
    private var bikeTypeSection: some View {
        Section {
            Picker("Type", selection: $bikeType) {
                ForEach(BikeType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: type.icon)
                        Text(type.rawValue)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.navigationLink)
        } header: {
            Text("Bike Type")
        }
    }
    
    private var purchaseSection: some View {
        Section {
            HStack {
                Text("Price")
                Spacer()
                TextField("0", text: $purchasePrice)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .price)
                Text("USD")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Purchase Info")
        }
    }
    
    private var componentsOptionSection: some View {
        Section {
            Toggle("Add default components", isOn: $addDefaultComponents)
            
            if addDefaultComponents {
                Text("Will add: \(bikeType.defaultComponents.map { $0.rawValue }.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } footer: {
            Text("Default components help you start tracking wear immediately")
        }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func saveBike() {
        Task { @MainActor in
            do {
                let bicycle = Bicycle(
                    name: name.trimmingCharacters(in: .whitespaces),
                    brand: brand.trimmingCharacters(in: .whitespaces),
                    model: model.trimmingCharacters(in: .whitespaces),
                    year: year,
                    bikeType: bikeType,
                    purchasePrice: Double(purchasePrice) ?? 0
                )
                
                // 先插入自行车，确保它在上下文中
                modelContext.insert(bicycle)
                
                if addDefaultComponents {
                    for componentType in bikeType.defaultComponents {
                        let component = Component(
                            name: componentType.rawValue,
                            componentType: componentType
                        )
                        component.bicycle = bicycle
                        modelContext.insert(component)
                    }
                }
                
                // 显式保存所有更改
                try modelContext.save()
                dismiss()
            } catch {
                print("Error saving bike: \(error)")
            }
        }
    }
}

#Preview {
    AddBikeView()
}
