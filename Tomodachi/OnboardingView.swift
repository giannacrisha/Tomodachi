import SwiftUI

private enum OnboardingStep {
    case name, task
}

struct OnboardingView: View {
    @AppStorage("tomodachiName") private var storedName: String = ""
    @AppStorage("tomodachiTask") private var storedTask: String = ""
    @AppStorage("onboardingComplete") private var onboardingComplete: Bool = false

    @State private var step: OnboardingStep = .name
    @State private var nameInput: String = ""
    @State private var taskInput: String = ""
    @State private var shake: Bool = false
    @FocusState private var fieldFocused: Bool

    private let ink = Color(red: 0.15, green: 0.12, blue: 0.10)
    private let bg  = Color(red: 0.95, green: 0.92, blue: 0.85)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                faceImage
                    .padding(.bottom, 28)

                stepContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(step)

                Spacer()
                Spacer()
            }
        }
        .onAppear { fieldFocused = true }
    }

    // MARK: - Subviews

    private var faceImage: some View {
        Image(step == .name ? "face_bored" : "face_happy")
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: 140, height: 140)
            .animation(.spring(duration: 0.4), value: step)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .name:
            stepView(
                headline: "Your Tomodachi is here.",
                subhead: "Give it a name so it knows you care.",
                placeholder: "Name your Tomodachi…",
                input: $nameInput,
                buttonLabel: "Next →",
                action: commitName
            )
        case .task:
            stepView(
                headline: "What's the habit?",
                subhead: "Your Tomodachi will hold you to it. Daily.",
                placeholder: "e.g. Water the plant",
                input: $taskInput,
                buttonLabel: "Let's go →",
                action: commitTask
            )
        }
    }

    private func stepView(
        headline: String,
        subhead: String,
        placeholder: String,
        input: Binding<String>,
        buttonLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text(headline)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(ink)
                    .multilineTextAlignment(.center)

                Text(subhead)
                    .font(.subheadline)
                    .foregroundStyle(ink.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 36)

            TextField(placeholder, text: input)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(.white, in: RoundedRectangle(cornerRadius: 14))
                .focused($fieldFocused)
                .submitLabel(.done)
                .onSubmit(action)
                .modifier(ShakeEffect(trigger: shake))
                .padding(.horizontal, 32)
                .padding(.bottom, 16)

            Button(action: action) {
                Text(buttonLabel)
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(ink)
                    .foregroundStyle(bg)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Actions

    private func commitName() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { triggerShake(); return }
        storedName = trimmed
        withAnimation(.easeInOut(duration: 0.35)) { step = .task }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { fieldFocused = true }
    }

    private func commitTask() {
        let trimmed = taskInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { triggerShake(); return }
        storedTask = trimmed
        withAnimation(.easeInOut(duration: 0.3)) { onboardingComplete = true }
    }

    private func triggerShake() {
        withAnimation(.spring(duration: 0.4)) { shake.toggle() }
    }
}

// MARK: - Shake modifier

struct ShakeEffect: AnimatableModifier {
    var trigger: Bool
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { _, _ in
                Task {
                    for x: CGFloat in [10, -10, 8, -8, 4, -4, 0] {
                        try? await Task.sleep(for: .milliseconds(40))
                        withAnimation(.linear(duration: 0.04)) { offset = x }
                    }
                }
            }
    }

    var animatableData: EmptyAnimatableData { EmptyAnimatableData() }
}

#Preview {
    OnboardingView()
}
