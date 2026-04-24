import Foundation
import Combine

enum Mood: String, CaseIterable {
    case happy
    case bored
    case sad
    case angry

    var emoji: String {
        switch self {
        case .happy:  return "🌟"
        case .bored:  return "😑"
        case .sad:    return "😢"
        case .angry:  return "😤"
        }
    }

    var displayName: String { rawValue.capitalized }

    var tagline: String {
        switch self {
        case .happy:  return "Your Tomodachi is thriving!"
        case .bored:  return "Your Tomodachi is waiting on you…"
        case .sad:    return "Hey. You forgot."
        case .angry:  return "Your Tomodachi is MAD."
        }
    }

    var imageName: String { "face_\(rawValue)" }

    var usesLightText: Bool {
        switch self {
        case .happy, .bored: return false
        case .sad, .angry:   return true
        }
    }

    var command: String { rawValue }
}

final class AppViewModel: ObservableObject {
    @Published private(set) var mood: Mood = .bored
    @Published var taskName: String = UserDefaults.standard.string(forKey: "tomodachiTask") ?? "Water the plant"

    @Published var tomodachiName: String = UserDefaults.standard.string(forKey: "tomodachiName") ?? "Tomodachi"

    let bluetooth = BluetoothManager()

    // MARK: - Actions

    func didCompleteTask() {
        setMood(.happy)
    }

    func didForgetTask() {
        setMood(.sad)
    }

    // MARK: - Private

    private func setMood(_ newMood: Mood) {
        mood = newMood
        bluetooth.sendCommand(newMood.command)
    }
}
