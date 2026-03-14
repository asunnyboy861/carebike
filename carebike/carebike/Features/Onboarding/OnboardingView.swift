import SwiftUI

struct OnboardingView: View {
    @AppStorage(Constants.Storage.onboardingCompleted) private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to BikeCare Pro",
            subtitle: "Your personal bike maintenance assistant",
            iconName: "bicycle.circle.fill",
            gradientColors: [Color.blue, Color.purple]
        ),
        OnboardingPage(
            title: "Track Your Rides",
            subtitle: "Record distance, speed, and routes for every ride",
            iconName: "map.fill",
            gradientColors: [Color.green, Color.blue]
        ),
        OnboardingPage(
            title: "Monitor Components",
            subtitle: "Get timely reminders for maintenance and replacements",
            iconName: "gearshape.fill",
            gradientColors: [Color.orange, Color.red]
        ),
        OnboardingPage(
            title: "Analyze Costs",
            subtitle: "Track spending and optimize your bike budget",
            iconName: "chart.bar.fill",
            gradientColors: [Color.purple, Color.pink]
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            
            bottomButtons
        }
        .background(Color(.systemBackground))
    }
    
    private var bottomButtons: some View {
        HStack(spacing: Constants.UI.defaultPadding) {
            if currentPage < pages.count - 1 {
                Button("Skip") {
                    completeOnboarding()
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Next") {
                    withAnimation {
                        currentPage += 1
                    }
                }
                .fontWeight(.semibold)
                .padding(.horizontal, Constants.UI.defaultPadding)
                .padding(.vertical, Constants.UI.smallPadding)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(Constants.UI.cornerRadius)
            } else {
                Button(action: completeOnboarding) {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Constants.UI.defaultPadding)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.UI.cornerRadius)
                }
            }
        }
        .padding(Constants.UI.defaultPadding)
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let iconName: String
    let gradientColors: [Color]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: Constants.UI.largePadding) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                
                Image(systemName: page.iconName)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: Constants.UI.smallPadding) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.UI.largePadding)
            }
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
