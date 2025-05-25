import Foundation

struct GameChallenge: Identifiable, Equatable {
    var id: String { title + station + (line?.rawValue ?? "") }
    let title: String
    let description: String
    let station: String
    let line: MetroLine?
}

let sampleChallenges: [GameChallenge] = [
    GameChallenge(title: "Graffiti Challenge", description: "Find a Metro sign or graffiti tag near LATTC.", station: "Grand/LATTC", line: .A),
    GameChallenge(title: "Historical Challenge", description: "Find a historical marker or plaque in Heritage Square.", station: "Heritage Sq", line: .A),
    GameChallenge(title: "Lantern Challenge", description: "Find a dragon or red lantern in Chinatown.", station: "Chinatown", line: .A),
    GameChallenge(title: "Marquee Challenge", description: "Find an old theater marquee.", station: "Historic Broadway", line: .A),
    GameChallenge(title: "Mochi Challenge", description: "Find a mochi shop in Little Tokyo.", station: "Little Tokyo/Arts Dist", line: .A),
    GameChallenge(title: "Mural Challenge", description: "Find a mural or train near the LA River bike path.", station: "Lincoln/Cypress", line: .A),
    GameChallenge(title: "Performance Challenge", description: "Find a fountain near The Broad.", station: "Grand Av Arts/Bunker Hill", line: .A),
    GameChallenge(title: "Poster Challenge", description: "Find a sports jersey near Crypto.com Arena.", station: "Pico", line: .A),
    GameChallenge(title: "Reflection Challenge", description: "Find a dramatic reflection photo of the lake.", station: "Westlake/MacArthur Park", line: .D),
    GameChallenge(title: "Signage Challenge", description: "Find a courthouse sign or public art.", station: "Civic Ctr/Grand Park", line: .D),
    GameChallenge(title: "Star Challenge", description: "Find a Walk of Fame star for someone you’ve heard of.", station: "Hollywood/Vine", line: .B),
    GameChallenge(title: "Staircase Challenge", description: "Find a staircase mural or street musician.", station: "Grand Av Arts/Bunker Hill", line: .E),
    GameChallenge(title: "Sticker Challenge", description: "Find a food truck or rally near the Rose Garden.", station: "Expo/Vermont", line: .E),
    GameChallenge(title: "Student Challenge", description: "Find a USC sign or student-related reference.", station: "Jefferson/USC", line: .E),
    GameChallenge(title: "Transfer Challenge", description: "Find a Metro transfer sign.", station: "Wilshire/Vermont", line: .B),
    GameChallenge(title: "Vending Challenge", description: "Find a paddle boat or vendor.", station: "Westlake/MacArthur Park", line: .B),
    GameChallenge(title: "Vintage Challenge", description: "Find a vintage store or Thai food sign nearby.", station: "Hollywood/Western", line: .B),
    GameChallenge(title: "Visuals Challenge", description: "Find a painted alley in the Arts District.", station: "Little Tokyo/Arts Dist", line: .E),
    GameChallenge(title: "Volunteer Challenge", description: "Find a dinosaur, rocket, or science museum object.", station: "Expo Park/USC", line: .E),
    GameChallenge(title: "Wellness Challenge", description: "Find a hospital sign from Kaiser or a health-related object.", station: "Vermont/Sunset", line: .B),
    GameChallenge(title: "Window Challenge", description: "Find a bookstore or creative window display.", station: "Vermont/Beverly", line: .B),
    GameChallenge(title: "Words Challenge", description: "Find a neon sign or taco stand nearby.", station: "Vermont/Santa Monica", line: .B),
    GameChallenge(title: "Zone Challenge", description: "Find a Korean sign or business with Hangul writing.", station: "Wilshire/Normandie", line: .D),
    GameChallenge(title: "Broadway Challenge", description: "Find a historic building plaque.", station: "Historic Broadway", line: .E),
    GameChallenge(title: "Bus Challenge", description: "Find a Metro bus connection map or transfer sign.", station: "Wilshire/Vermont", line: .D),
    GameChallenge(title: "Chess Challenge", description: "Find a chess game or protest sign.", station: "Pershing Square", line: .B),
    GameChallenge(title: "Concert Challenge", description: "Find a concert poster or merch nearby.", station: "Pico", line: .E),
    GameChallenge(title: "K-Town Challenge", description: "Find a karaoke place or beauty store in Koreatown.", station: "Wilshire/Western", line: .D),
    GameChallenge(title: "Medical Challenge", description: "Find a medical or training facility label nearby.", station: "LATTC/Ortho Institute", line: .E),
    GameChallenge(title: "Mural Challenge", description: "Find a local mural or a Metro bridge near the station.", station: "Pico/Aliso", line: .E),
    GameChallenge(title: "Music Challenge", description: "Find a mariachi band reference or musical image.", station: "Mariachi Plaza", line: .E),
    GameChallenge(title: "Park Challenge", description: "Find a protest sign or group at Grand Park.", station: "Civic Ctr/Grand Park", line: .B),
    GameChallenge(title: "Purple Challenge", description: "Find a purple flower or purple item nearby.", station: "Pershing Square", line: .D),
]
