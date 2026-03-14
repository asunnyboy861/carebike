import SwiftUI

struct TutorialDetailView: View {
    let tutorial: Tutorial
    
    @State private var currentStep = 0
    @State private var showTips = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                
                progressIndicator
                
                stepsSection
                
                navigationButtons
            }
            .padding()
        }
        .navigationTitle(tutorial.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: tutorial.icon)
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tutorial.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text(tutorial.difficulty.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(tutorial.difficulty.color.opacity(0.2))
                            .foregroundColor(tutorial.difficulty.color)
                            .cornerRadius(4)
                        
                        Label("\(tutorial.estimatedMinutes) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Text(tutorial.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var progressIndicator: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(currentStep + 1) of \(tutorial.steps.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: Double(currentStep + 1), total: Double(tutorial.steps.count))
        }
    }
    
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !tutorial.steps.isEmpty {
                let step = tutorial.steps[currentStep]
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Step \(currentStep + 1)")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                        
                        Text(step.title)
                            .font(.headline)
                    }
                    
                    Text(step.instruction)
                        .font(.body)
                    
                    if showTips {
                        if let tip = step.tip {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                
                                Text(tip)
                                    .font(.subheadline)
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        if let warning = step.warning {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                
                                Text(warning)
                                    .font(.subheadline)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            Button(action: previousStep) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(currentStep > 0 ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(currentStep == 0)
            
            Button(action: nextStep) {
                HStack {
                    Text(currentStep == tutorial.steps.count - 1 ? "Complete" : "Next")
                    Image(systemName: currentStep == tutorial.steps.count - 1 ? "checkmark" : "chevron.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    private func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    private func nextStep() {
        if currentStep < tutorial.steps.count - 1 {
            currentStep += 1
        }
    }
}

#Preview {
    NavigationStack {
        TutorialDetailView(tutorial: Tutorial(
            title: "How to Clean Your Chain",
            description: "Learn the proper technique for cleaning and lubricating your bike chain",
            category: .drivetrain,
            difficulty: .beginner,
            estimatedMinutes: 15,
            icon: "link",
            steps: [
                TutorialStep(
                    title: "Prepare Your Workspace",
                    instruction: "Place your bike in a work stand or flip it upside down. Put down a mat or newspaper to catch drips.",
                    tip: "Working in a well-ventilated area is recommended when using cleaning solvents.",
                    warning: nil
                ),
                TutorialStep(
                    title: "Apply Degreaser",
                    instruction: "Apply chain degreaser to the chain while backpedaling. Make sure to cover all links.",
                    tip: "Let the degreaser sit for 2-3 minutes for best results.",
                    warning: "Avoid getting degreaser on brake pads or rotors."
                )
            ]
        ))
    }
}
