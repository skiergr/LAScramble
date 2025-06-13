import Foundation

struct GameChallenge: Identifiable, Equatable {
    var id: String { title + station + (line?.rawValue ?? "") }
    let title: String
    let description: String
    let station: String
    let line: MetroLine?
    let canFail: Bool?
}


let sampleChallenges: [GameChallenge] = [
    GameChallenge(title: "Graffiti Challenge", description: "Find a Metro sign or graffiti tag near LATTC.", station: "Grand/LATTC", line: .A, canFail: true),
    GameChallenge(title: "Sample challenge", description: "idk rules its a sample fix.", station: "Southwest Museum", line: .A, canFail: false),
    GameChallenge(title: "Historical Challenge", description: "Find a historical marker or plaque in Heritage Square.", station: "Heritage Sq", line: .A, canFail: true),
    GameChallenge(title: "Lantern Challenge", description: "Find a dragon or red lantern in Chinatown.", station: "Chinatown", line: .A, canFail: false),
    GameChallenge(title: "Marquee Challenge", description: "Find an old theater marquee.", station: "Historic Broadway", line: .A, canFail: true),
    GameChallenge(title: "Mochi Challenge", description: "Find a mochi shop in Little Tokyo.", station: "Little Tokyo/Arts Dist", line: .A, canFail: false),
    GameChallenge(title: "Mural Challenge", description: "Find a mural or train near the LA River bike path.", station: "Lincoln/Cypress", line: .A, canFail: true),
    GameChallenge(title: "Performance Challenge", description: "Find a fountain near The Broad.", station: "Grand Av Arts/Bunker Hill", line: .A, canFail: false),
    GameChallenge(title: "Poster Challenge", description: "Find a sports jersey near Crypto.com Arena.", station: "Pico", line: .A, canFail: true),
    GameChallenge(title: "Reflection Challenge", description: "Find a dramatic reflection photo of the lake.", station: "Westlake/MacArthur Park", line: .D, canFail: false),
    GameChallenge(title: "Signage Challenge", description: "Find a courthouse sign or public art.", station: "Civic Ctr/Grand Park", line: .D, canFail: true),
    GameChallenge(title: "Star Challenge", description: "Find a Walk of Fame star for someone you’ve heard of.", station: "Hollywood/Vine", line: .B, canFail: false),
    GameChallenge(title: "Staircase Challenge", description: "Find a staircase mural or street musician.", station: "Grand Av Arts/Bunker Hill", line: .E, canFail: true),
    GameChallenge(title: "Sticker Challenge", description: "Find a food truck or rally near the Rose Garden.", station: "Expo/Vermont", line: .E, canFail: false),
    GameChallenge(title: "Student Challenge", description: "Find a USC sign or student-related reference.", station: "Jefferson/USC", line: .E, canFail: true),
    GameChallenge(title: "Transfer Challenge", description: "Find a Metro transfer sign.", station: "Wilshire/Vermont", line: .B, canFail: false),
    GameChallenge(title: "Vending Challenge", description: "Find a paddle boat or vendor.", station: "Westlake/MacArthur Park", line: .B, canFail: true),
    GameChallenge(title: "Vintage Challenge", description: "Find a vintage store or Thai food sign nearby.", station: "Hollywood/Western", line: .B, canFail: false),
    GameChallenge(title: "Visuals Challenge", description: "Find a painted alley in the Arts District.", station: "Little Tokyo/Arts Dist", line: .E, canFail: true),
    GameChallenge(title: "Volunteer Challenge", description: "Find a dinosaur, rocket, or science museum object.", station: "Expo Park/USC", line: .E, canFail: false),
    GameChallenge(title: "Wellness Challenge", description: "Find a hospital sign from Kaiser or a health-related object.", station: "Vermont/Sunset", line: .B, canFail: true),
    GameChallenge(title: "Window Challenge", description: "Find a bookstore or creative window display.", station: "Vermont/Beverly", line: .B, canFail: false),
    GameChallenge(title: "Words Challenge", description: "Find a neon sign or taco stand nearby.", station: "Vermont/Santa Monica", line: .B, canFail: true),
    GameChallenge(title: "Zone Challenge", description: "Find a Korean sign or business with Hangul writing.", station: "Wilshire/Normandie", line: .D, canFail: false),
    GameChallenge(title: "Broadway Challenge", description: "Find a historic building plaque.", station: "Historic Broadway", line: .E, canFail: true),
    GameChallenge(title: "Bus Challenge", description: "Find a Metro bus connection map or transfer sign.", station: "Wilshire/Vermont", line: .D, canFail: false),
    GameChallenge(title: "Chess Challenge", description: "Find a chess game or protest sign.", station: "Pershing Square", line: .B, canFail: true),
    GameChallenge(title: "Concert Challenge", description: "Find a concert poster or merch nearby.", station: "Pico", line: .E, canFail: false),
    GameChallenge(title: "K-Town Challenge", description: "Find a karaoke place or beauty store in Koreatown.", station: "Wilshire/Western", line: .D, canFail: true),
    GameChallenge(title: "Medical Challenge", description: "Find a medical or training facility label nearby.", station: "LATTC/Ortho Institute", line: .E, canFail: false),
    GameChallenge(title: "Mural Challenge", description: "Find a local mural or a Metro bridge near the station.", station: "Pico/Aliso", line: .E, canFail: true),
    GameChallenge(title: "Music Challenge", description: "Find a mariachi band reference or musical image.", station: "Mariachi Plaza", line: .E, canFail: false),
    GameChallenge(title: "Park Challenge", description: "Find a protest sign or group at Grand Park.", station: "Civic Ctr/Grand Park", line: .B, canFail: true),
    GameChallenge(title: "Purple Challenge", description: "Find a purple flower or purple item nearby.", station: "Pershing Square", line: .D, canFail: false),
]
