import Foundation

struct GameChallenge: Identifiable, Equatable {
    var id: String { title + station + (line?.rawValue ?? "") }
    let title: String
    let description: String
    let station: String
    let line: MetroLine?
}


let sampleChallenges: [GameChallenge] = [
    GameChallenge(title: "Strike a Pose", description: "Take a funny group photo at Mariachi Plaza.", station: "Mariachi Plaza", line: .E),
    GameChallenge(title: "Local History", description: "Find and record a short video explaining a nearby mural.", station: "Expo/Vermont", line: .E),
    GameChallenge(title: "Metro Selfie", description: "Snap a selfie with a Metro worker (with permission!).", station: "Hollywood/Vine", line: .B),
    GameChallenge(title: "Train Trivia", description: "Ask a stranger on the platform to share a fact about LA.", station: "Grand/LATTC", line: .A),
    GameChallenge(title: "Soundtrack Time", description: "Play a song that fits the mood of the station and dance for 10 seconds.", station: "Pico", line: .E)
]

