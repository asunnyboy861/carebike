import SwiftUI

struct ProgressRing: View {
    var progress: Double
    var lineWidth: CGFloat = 12
    var size: CGFloat = 100
    var showPercentage: Bool = true
    var color: Color = .blue
    var backgroundColor: Color = .gray.opacity(0.2)
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            if showPercentage {
                VStack(spacing: 2) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                }
            }
        }
        .frame(width: size, height: size)
    }
    
    init(progress: Double, lineWidth: CGFloat = 12, size: CGFloat = 100, showPercentage: Bool = true, color: Color = .blue, backgroundColor: Color = .gray.opacity(0.2)) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
        self.showPercentage = showPercentage
        self.color = color
        self.backgroundColor = backgroundColor
    }
}

struct ComponentProgressRing: View {
    let component: Component
    
    var body: some View {
        ProgressRing(
            progress: component.usagePercentage / 100,
            lineWidth: 8,
            size: 80,
            color: healthColor
        )
        .overlay(
            Image(systemName: component.componentType.icon)
                .font(.system(size: 20))
                .foregroundColor(healthColor)
        )
    }
    
    private var healthColor: Color {
        switch component.healthStatus {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .yellow
        case .poor: return .orange
        case .replaceNow: return .red
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressRing(progress: 0.75, color: .blue)
        ProgressRing(progress: 0.5, color: .green)
        ProgressRing(progress: 0.9, color: .red)
    }
    .padding()
}
