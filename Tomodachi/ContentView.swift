import SwiftUI

struct ContentView: View {
    @StateObject private var vm = AppViewModel()

    private var ink: Color { vm.mood.usesLightText ? .white : Color(red: 0.15, green: 0.12, blue: 0.10) }

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                connectionBanner
                Spacer()
                moodDisplay
                Spacer()
                taskSection
                Spacer()
                actionButtons
                    .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(vm.mood.usesLightText ? .dark : .light)
    }

    // MARK: - Subviews

    private var background: some View {
        Color(mood: vm.mood)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: vm.mood)
    }

    private var connectionBanner: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(vm.bluetooth.connectionState.isConnected ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
                .animation(.easeInOut, value: vm.bluetooth.connectionState.isConnected)
            Text(vm.bluetooth.connectionState.displayText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(ink.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
        .padding(.top, 16)
    }

    private var moodDisplay: some View {
        VStack(spacing: 16) {
            Image(vm.mood.imageName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 160, height: 160)
                .shadow(radius: 8)
                .animation(.spring(duration: 0.4), value: vm.mood)

            VStack(spacing: 6) {
                Text(vm.tomodachiName.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(4)
                    .foregroundStyle(ink.opacity(0.45))

                Text(vm.mood.displayName)
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(ink)
                    .animation(.spring(duration: 0.4), value: vm.mood)

                Text(vm.mood.tagline)
                    .font(.subheadline)
                    .foregroundStyle(ink.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .animation(.easeInOut(duration: 0.3), value: vm.mood)
            }
        }
    }

    private var taskSection: some View {
        VStack(spacing: 8) {
            Text("Today's task")
                .font(.caption)
                .fontWeight(.semibold)
                .tracking(2)
                .foregroundStyle(ink.opacity(0.45))
                .textCase(.uppercase)

            Text(vm.taskName)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(ink)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 32)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 32)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: vm.didCompleteTask) {
                Text("I did it ✓")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(ink)
                    .foregroundStyle(Color(mood: vm.mood))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button(action: vm.didForgetTask) {
                Text("I forgot…")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(ink.opacity(0.45))
            }
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Mood Color

private extension Color {
    init(mood: Mood) {
        switch mood {
        case .happy:  self = Color(red: 0.96, green: 0.86, blue: 0.42) // warm yellow
        case .bored:  self = Color(red: 0.95, green: 0.92, blue: 0.85) // neutral beige
        case .sad:    self = Color(red: 0.49, green: 0.77, blue: 0.91) // sky blue
        case .angry:  self = Color(red: 0.91, green: 0.44, blue: 0.42) // coral red
        }
    }
}

#Preview {
    ContentView()
}
