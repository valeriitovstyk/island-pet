import ActivityKit
import Shared
import SwiftUI

struct PetHomeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var state = PetAttributes.ContentState.initial()
    @State private var expanded = false
    @State private var running = false
    @State private var available = true
    @State private var autoRestart = PetStore.autoRestart

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.08, blue: 0.11).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 28) {
                    capsule
                    statusCard
                    if !available { disabledHint }
                    Spacer(minLength: 40)
                    controls
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
        }
        .preferredColorScheme(.dark)
        .task { await refresh() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await refresh() } }
        }
        .onOpenURL { url in
            guard url.scheme == "islandpet" else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) { expanded = true }
            Task { await refresh() }
        }
    }

    private var capsule: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                PetView(mood: state.mood, size: expanded ? 128 : 48, animated: true)
                if !expanded {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(state.mood.title).font(.subheadline.bold())
                        Text(timerInterval: Date.now...max(Date.now.addingTimeInterval(1), state.nextChangeAt), countsDown: true)
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.white.opacity(0.65))
                    }
                    Spacer()
                }
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.65))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) { expanded.toggle() }
            }

            if expanded {
                Text(state.mood.title)
                    .font(.title3.bold())
                    .contentTransition(.opacity)
                Text("Наступний настрій — \(state.nextMoodTitle)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.68))
                actionButtons
            }
        }
        .padding(expanded ? 20 : 12)
        .frame(maxWidth: .infinity)
        .background(.black, in: RoundedRectangle(cornerRadius: expanded ? 30 : 28))
        .animation(.spring(response: 0.5, dampingFraction: 0.78), value: expanded)
    }

    private var actionButtons: some View {
        HStack(spacing: 8) {
            actionButton("Погодувати", symbol: "fork.knife", action: .feed)
            actionButton("Погратися", symbol: "gamecontroller", action: .play)
            actionButton("Спати", symbol: "moon.zzz", action: .sleep)
        }
    }

    private func actionButton(_ title: String, symbol: String, action: PetAction) -> some View {
        Button {
            Task { state = await PetActivityManager.perform(action); running = PetActivityManager.isRunning }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: symbol)
                Text(title).font(.caption2.bold()).lineLimit(1).minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 13))
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Стан персонажа").font(.title3.bold())
            metric("Енергія", value: state.energy, color: .cyan)
            metric("Настрій", value: state.joy, color: .pink)
            metric("Ситість", value: state.food, color: PetPalette.accent)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 24))
    }

    private func metric(_ title: String, value: Int, color: Color) -> some View {
        VStack(spacing: 7) {
            HStack {
                Text(title).font(.subheadline)
                Spacer()
                Text("\(value)%").font(.subheadline.monospacedDigit()).foregroundStyle(.white.opacity(0.7))
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.12))
                    Capsule().fill(color).frame(width: geometry.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 8)
        }
    }

    private var disabledHint: some View {
        Text("Live Activities вимкнені. Увімкніть їх у Параметри → IslandPet → Live Activities.")
            .font(.footnote)
            .foregroundStyle(.yellow)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var controls: some View {
        VStack(spacing: 17) {
            Button {
                Task {
                    if running { await PetActivityManager.stop() }
                    else { await PetActivityManager.start(with: state) }
                    running = PetActivityManager.isRunning
                }
            } label: {
                Text(running ? "Прибрати з екрана блокування" : "Показати на екрані блокування")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(.plain)
            .background(PetPalette.accent, in: RoundedRectangle(cornerRadius: 18))
            .disabled(!available && !running)

            Toggle("Автоматично перезапускати", isOn: $autoRestart)
                .font(.subheadline)
                .tint(PetPalette.accent)
                .onChange(of: autoRestart) { _, newValue in PetStore.autoRestart = newValue }
        }
    }

    private func refresh() async {
        state = await PetActivityManager.refreshOnOpen()
        running = PetActivityManager.isRunning
        available = PetActivityManager.isAvailable
        autoRestart = PetStore.autoRestart
    }
}
