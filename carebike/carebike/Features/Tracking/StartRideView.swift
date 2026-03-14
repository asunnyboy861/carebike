import SwiftUI
import SwiftData

struct StartRideView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bicycle.name) private var bicycles: [Bicycle]
    
    @State private var selectedBike: Bicycle?
    @State private var showActiveRide = false
    @State private var showingAddBike = false
    
    var body: some View {
        NavigationStack {
            Group {
                if bicycles.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle("Track")
        }
        .sheet(isPresented: $showActiveRide) {
            NavigationStack {
                ActiveRideView(initialBike: selectedBike)
            }
        }
        .sheet(isPresented: $showingAddBike) {
            AddBikeView()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "bicycle")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            Text("No Bikes Yet")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Add your first bike to start tracking rides.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showingAddBike = true }) {
                Label("Add Bike", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(Constants.UI.cornerRadius)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    private var contentView: some View {
        VStack(spacing: 24) {
            Image(systemName: "bicycle.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Ready to Ride?")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Bike")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Bike", selection: $selectedBike) {
                    ForEach(bicycles) { bike in
                        Text(bike.name).tag(bike as Bicycle?)
                    }
                }
                .pickerStyle(.menu)
                .onAppear {
                    if selectedBike == nil {
                        selectedBike = bicycles.first
                    }
                }
            }
            .padding(.horizontal)
            
            Button(action: { showActiveRide = true }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Ride")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(Constants.UI.cornerRadius)
            }
            .padding(.horizontal, 40)
            
            NavigationLink(destination: RideHistoryView()) {
                Text("View Ride History")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}

#Preview {
    StartRideView()
        .modelContainer(PersistenceController(inMemory: true).container)
}
