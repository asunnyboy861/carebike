import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(40)
    }
}

struct FullScreenLoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(Color.black.opacity(0.7))
            .cornerRadius(16)
        }
    }
}

struct SavingIndicator: View {
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Saving...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

#Preview {
    VStack(spacing: 40) {
        LoadingView()
        SavingIndicator()
    }
    .padding()
}
