import Foundation

struct GameChallenge: Identifiable, Equatable {
    var id: String { title + station + (line?.rawValue ?? "") }
    let title: String
    let description: String
    let station: String
    let line: MetroLine?
}

let sampleChallenges: [GameChallenge] = [
    // Mariachi Plaza
    GameChallenge(title: "Strike a Pose", description: "Take a funny group photo at Mariachi Plaza.", station: "Mariachi Plaza", line: .E),
    GameChallenge(title: "Mariachi Music Hunt", description: "Find a poster or sign referencing music nearby.", station: "Mariachi Plaza", line: .E),
    GameChallenge(title: "Cultural Colors", description: "Find something colorful that represents local culture.", station: "Mariachi Plaza", line: .E),

    // Expo/Vermont
    GameChallenge(title: "Local History", description: "Find and record a short video explaining a nearby mural.", station: "Expo/Vermont", line: .E),
    GameChallenge(title: "Trojan Spotting", description: "Find USC colors, logos, or students and take a pic.", station: "Expo/Vermont", line: .E),
    GameChallenge(title: "Campus Vibes", description: "Interview a student about their favorite class.", station: "Expo/Vermont", line: .E),

    // Hollywood/Vine
    GameChallenge(title: "Metro Selfie", description: "Snap a selfie with a Metro worker (with permission!).", station: "Hollywood/Vine", line: .B),
    GameChallenge(title: "Star Search", description: "Find a Walk of Fame star and pose with it.", station: "Hollywood/Vine", line: .B),
    GameChallenge(title: "Movie Buff", description: "Name 3 movies that were filmed near this station.", station: "Hollywood/Vine", line: .B),

    // Grand/LATTC
    GameChallenge(title: "Train Trivia", description: "Ask a stranger on the platform to share a fact about LA.", station: "Grand/LATTC", line: .A),
    GameChallenge(title: "Tech & Trade", description: "Find a tool or item that symbolizes a trade skill.", station: "Grand/LATTC", line: .A),
    GameChallenge(title: "Public Art", description: "Locate and take a photo with a piece of station art.", station: "Grand/LATTC", line: .A),

    // Pico
    GameChallenge(title: "Soundtrack Time", description: "Play a song that fits the mood of the station and dance for 10 seconds.", station: "Pico", line: .E),
    GameChallenge(title: "Sports Spot", description: "Find something related to the Lakers or Clippers nearby.", station: "Pico", line: .E),
    GameChallenge(title: "Convention Quest", description: "Snap a photo with a nearby convention-goer.", station: "Pico", line: .E)
]
