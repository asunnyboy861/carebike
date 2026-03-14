import SwiftUI
import SwiftData

struct EditBikeView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var bicycle: Bicycle
    
    @State private var name: String
    @State private var brand: String
    @State private var model: String
    @State private var year: Int
    @State private var bikeType: BikeType
    @State private var purchasePrice: String
    
    init(bicycle: Bicycle) {
        self.bicycle = bicycle
        _name = State(initialValue: bicycle.name)
        _brand = State(initialValue: bicycle.brand)
        _model = State(initialValue: bicycle.model)
        _year = State(initialValue: bicycle.year)
        _bikeType = State(initialValue: bicycle.bikeType)
        _purchasePrice = State(initialValue: String(bicycle.purchasePrice))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                bikeTypeSection
                purchaseSection
                distanceSection
            }
            .navigationTitle("Edit Bike")
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
            TextField("Brand", text: $brand)
            TextField("Model", text: $model)
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
                Text("USD")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Purchase Info")
        }
    }
    
    private var distanceSection: some View {
        Section {
            HStack {
                Text("Total Distance")
                Spacer()
                Text(bicycle.totalDistance.formattedDistance)
                    .foregroundColor(.secondary)
            }
            
            Text("Distance is updated automatically from rides")
                .font(.caption)
                .foregroundColor(.secondary)
        } header: {
            Text("Distance")
        }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func saveChanges() {
        bicycle.name = name.trimmingCharacters(in: .whitespaces)
        bicycle.brand = brand.trimmingCharacters(in: .whitespaces)
        bicycle.model = model.trimmingCharacters(in: .whitespaces)
        bicycle.year = year
        bicycle.bikeType = bikeType
        bicycle.purchasePrice = Double(purchasePrice) ?? bicycle.purchasePrice
        
        dismiss()
    }
}

#Preview {
    EditBikeView(bicycle: Bicycle(name: "My Bike", brand: "Brand", model: "Model", year: 2024, bikeType: .road))
}
