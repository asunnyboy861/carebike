import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Feedback API endpoint
    private let feedbackAPIURL = "https://feedback-board.iocompile67692.workers.dev/api/feedback"
    
    // Form fields
    @State private var selectedTopic: FeedbackTopic = .general
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    
    // UI states
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isEmailValid = true
    
    // Predefined topics for bike maintenance app
    enum FeedbackTopic: String, CaseIterable, Identifiable {
        case general = "General Feedback"
        case bug = "Bug Report"
        case feature = "Feature Request"
        case sync = "Sync & Cloud Issues"
        case tracking = "Ride Tracking Problem"
        case maintenance = "Maintenance Alert Issue"
        case ui = "UI/UX Feedback"
        case other = "Other"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .general: return "bubble.left.fill"
            case .bug: return "ant.fill"
            case .feature: return "lightbulb.fill"
            case .sync: return "icloud.slash.fill"
            case .tracking: return "location.slash.fill"
            case .maintenance: return "wrench.and.screwdriver.fill"
            case .ui: return "paintbrush.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .general: return .blue
            case .bug: return .red
            case .feature: return .yellow
            case .sync: return .purple
            case .tracking: return .green
            case .maintenance: return .orange
            case .ui: return .pink
            case .other: return .gray
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidEmail(email) &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty &&
        message.count >= 10
    }
    
    var body: some View {
        NavigationStack {
            Form {
                topicSection
                contactSection
                messageSection
                submitSection
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Thank You!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your feedback has been submitted successfully. We'll get back to you soon.")
            }
            .alert("Submission Failed", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
                Button("Try Again") {
                    submitFeedback()
                }
            } message: {
                Text(errorMessage)
            }
            .disabled(isSubmitting)
            .overlay {
                if isSubmitting {
                    ProgressView("Sending...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(Constants.UI.cornerRadius)
                        .shadow(radius: 10)
                }
            }
        }
    }
    
    // MARK: - Topic Selection Section
    private var topicSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FeedbackTopic.allCases) { topic in
                        TopicButton(
                            topic: topic,
                            isSelected: selectedTopic == topic,
                            action: { selectedTopic = topic }
                        )
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        } header: {
            Text("What can we help you with?")
                .textCase(nil)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Contact Information Section
    private var contactSection: some View {
        Section {
            TextField("Your Name", text: $name)
                .textContentType(.name)
                .autocapitalization(.words)
            
            TextField("Email Address", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .onChange(of: email) { _, newValue in
                    if !newValue.isEmpty {
                        isEmailValid = isValidEmail(newValue)
                    }
                }
            
            if !isEmailValid && !email.isEmpty {
                Text("Please enter a valid email address")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        } header: {
            Text("Contact Information")
        } footer: {
            Text("We'll use this email to respond to your inquiry")
        }
    }
    
    // MARK: - Message Section
    private var messageSection: some View {
        Section {
            TextEditor(text: $message)
                .frame(minHeight: 120)
                .overlay(alignment: .topLeading) {
                    if message.isEmpty {
                        Text("Describe your issue or suggestion in detail...")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                }
            
            HStack {
                Spacer()
                Text("\(message.count) characters")
                    .font(.caption)
                    .foregroundColor(message.count < 10 ? .red : .secondary)
            }
        } header: {
            Text("Message")
        } footer: {
            Text("Please provide as much detail as possible so we can help you better (minimum 10 characters)")
        }
    }
    
    // MARK: - Submit Section
    private var submitSection: some View {
        Section {
            Button(action: submitFeedback) {
                HStack {
                    Spacer()
                    Text("Submit Feedback")
                        .font(.headline)
                    Spacer()
                }
            }
            .disabled(!isFormValid || isSubmitting)
            .listRowBackground(
                isFormValid && !isSubmitting ? Color.blue : Color.gray.opacity(0.3)
            )
            .foregroundColor(isFormValid && !isSubmitting ? .white : .secondary)
        }
        .listRowInsets(EdgeInsets())
    }
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func submitFeedback() {
        guard isFormValid else { return }
        
        isSubmitting = true
        
        let feedbackData: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespaces),
            "email": email.trimmingCharacters(in: .whitespaces).lowercased(),
            "subject": selectedTopic.rawValue,
            "message": message.trimmingCharacters(in: .whitespaces),
            "app_name": Constants.App.name,
            "app_version": "\(Constants.App.version) (\(Constants.App.build))"
        ]
        
        guard let url = URL(string: feedbackAPIURL) else {
            showError("Invalid API URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: feedbackData)
        } catch {
            showError("Failed to encode feedback data")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                
                if let error = error {
                    showError("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    showError("Invalid server response")
                    return
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    showSuccessAlert = true
                case 400:
                    showError("Invalid request. Please check your input.")
                case 429:
                    showError("Too many requests. Please try again later.")
                case 500...599:
                    showError("Server error. Please try again later.")
                default:
                    showError("Unexpected error (Status: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
        isSubmitting = false
    }
}

// MARK: - Topic Button Component
struct TopicButton: View {
    let topic: ContactSupportView.FeedbackTopic
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: topic.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : topic.color)
                
                Text(topic.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 80)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(isSelected ? topic.color : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? topic.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    ContactSupportView()
}
