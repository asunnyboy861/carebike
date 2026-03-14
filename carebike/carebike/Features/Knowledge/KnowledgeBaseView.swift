import SwiftUI

struct KnowledgeBaseView: View {
    @State private var searchText = ""
    @State private var selectedCategory: TutorialCategory?
    @StateObject private var viewModel = KnowledgeViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(TutorialCategory.allCases, id: \.self) { category in
                    Section(category.rawValue) {
                        ForEach(filteredTutorials.filter { $0.category == category }) { tutorial in
                            NavigationLink(value: tutorial) {
                                TutorialRow(tutorial: tutorial)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Knowledge Base")
            .navigationDestination(for: Tutorial.self) { tutorial in
                TutorialDetailView(tutorial: tutorial)
            }
        }
    }
    
    private var filteredTutorials: [Tutorial] {
        if searchText.isEmpty {
            return viewModel.tutorials
        }
        return viewModel.tutorials.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
}

struct TutorialRow: View {
    let tutorial: Tutorial
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tutorial.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tutorial.title)
                    .font(.headline)
                
                Text(tutorial.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Label(tutorial.difficulty.rawValue, systemImage: "chart.bar")
                    Label("\(tutorial.estimatedMinutes) min", systemImage: "clock")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

enum TutorialCategory: String, CaseIterable {
    case basics = "Basics"
    case drivetrain = "Drivetrain"
    case brakes = "Brakes"
    case wheels = "Wheels & Tires"
    case suspension = "Suspension"
    case advanced = "Advanced"
}

enum TutorialDifficulty: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

struct Tutorial: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let category: TutorialCategory
    let difficulty: TutorialDifficulty
    let estimatedMinutes: Int
    let icon: String
    let steps: [TutorialStep]
    
    static func == (lhs: Tutorial, rhs: Tutorial) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TutorialStep: Identifiable {
    let id = UUID()
    let title: String
    let instruction: String
    let tip: String?
    let warning: String?
}

#Preview {
    KnowledgeBaseView()
}
