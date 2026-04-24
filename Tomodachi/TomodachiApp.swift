import SwiftUI

@main
struct TomodachiApp: App {
    @AppStorage("onboardingComplete") private var onboardingComplete: Bool = false

    var body: some Scene {
        WindowGroup {
            if onboardingComplete {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}
