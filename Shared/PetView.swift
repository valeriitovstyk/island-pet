import SwiftUI

public enum PetPalette {
    public static let accent = Color(red: 1, green: 138.0 / 255, blue: 61.0 / 255)
}

public struct PetView: View {
    public let mood: PetMood
    public let size: CGFloat
    public let animated: Bool

    @State private var swaying = false
    @State private var blinking = false
    @State private var bouncing = false

    public init(mood: PetMood, size: CGFloat, animated: Bool) {
        self.mood = mood
        self.size = size
        self.animated = animated
    }

    public var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.green)
                .frame(width: size * 0.26, height: size * 0.13)
                .rotationEffect(.degrees(-35))
                .offset(x: size * 0.12, y: -size * 0.43)

            Ellipse()
                .fill(PetPalette.accent)
                .frame(width: size * 0.84, height: size * 0.78)
                .overlay {
                    Ellipse()
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: size * 0.025)
                }

            HStack(spacing: size * 0.21) {
                eye
                eye
            }
            .offset(y: -size * 0.08)

            HStack(spacing: size * 0.42) {
                Circle().fill(Color.pink.opacity(0.65))
                Circle().fill(Color.pink.opacity(0.65))
            }
            .frame(width: size * 0.54)
            .frame(height: size * 0.11)
            .offset(y: size * 0.08)

            mouth
                .offset(y: size * 0.15)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(animated && swaying ? 5 : -5))
        .offset(y: animated && bouncing ? -size * 0.12 : 0)
        .contentTransition(.opacity)
        .onAppear {
            guard animated else { return }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                swaying = true
            }
        }
        .task(id: animated) {
            guard animated else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 3_200_000_000)
                blinking = true
                try? await Task.sleep(nanoseconds: 140_000_000)
                blinking = false
            }
        }
        .onTapGesture {
            guard animated else { return }
            withAnimation(.spring(response: 0.22, dampingFraction: 0.45)) { bouncing = true }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.55).delay(0.16)) { bouncing = false }
        }
    }

    @ViewBuilder
    private var eye: some View {
        if mood == .sleeping || blinking {
            Capsule()
                .fill(Color(red: 0.25, green: 0.12, blue: 0.07))
                .frame(width: size * 0.12, height: size * 0.025)
        } else {
            Ellipse()
                .fill(Color(red: 0.23, green: 0.10, blue: 0.07))
                .frame(width: size * 0.10, height: size * 0.14)
                .overlay(alignment: .topLeading) {
                    Circle().fill(.white)
                        .frame(width: size * 0.028, height: size * 0.028)
                        .offset(x: size * 0.025, y: size * 0.02)
                }
        }
    }

    @ViewBuilder
    private var mouth: some View {
        switch mood {
        case .eating:
            Ellipse().fill(Color(red: 0.35, green: 0.08, blue: 0.09))
                .frame(width: size * 0.12, height: size * 0.17)
        case .bored, .sleeping:
            Capsule().fill(Color(red: 0.35, green: 0.08, blue: 0.09))
                .frame(width: size * 0.13, height: size * 0.025)
        case .hungry:
            PetSmile(curvature: -0.08)
                .stroke(Color(red: 0.35, green: 0.08, blue: 0.09), style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round))
                .frame(width: size * 0.18, height: size * 0.08)
        case .playing:
            PetSmile(curvature: 0.22)
                .stroke(Color(red: 0.35, green: 0.08, blue: 0.09), style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round))
                .frame(width: size * 0.22, height: size * 0.11)
        case .happy:
            PetSmile(curvature: 0.45)
                .stroke(Color(red: 0.35, green: 0.08, blue: 0.09), style: StrokeStyle(lineWidth: size * 0.028, lineCap: .round))
                .frame(width: size * 0.25, height: size * 0.14)
        }
    }
}

private struct PetSmile: Shape {
    let curvature: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                          control: CGPoint(x: rect.midX, y: rect.midY + rect.height * curvature))
        return path
    }
}
