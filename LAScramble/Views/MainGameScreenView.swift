import SwiftUI
import FirebaseFirestore

struct MainGameScreenView: View {
    var gameID: String
    var teamID: String

    @State private var selectedStation: Station?
    @State private var selectedChallenge: GameChallenge?
    @State private var unlockedChallenges: [GameChallenge] = []
    @State private var completedChallenges: [GameChallenge] = []
    @State private var otherTeamsUnlocked: [String: [GameChallenge]] = [:]
    @State private var otherTeamIDs: [String] = []
    @State private var attachedListeners: Set<String> = []

    var body: some View {
        if gameID.isEmpty || teamID.isEmpty {
            VStack {
                Text("❌ Error: Game ID or Team ID missing.")
                Text("gameID=\(gameID), teamID=\(teamID)")
            }
        } else {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    GeometryReader { geometry in
                        ZStack {
                            Image("metro_map")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width, height: geometry.size.height)

                            ForEach(sampleStations) { station in
                                Button(action: {
                                    selectedStation = station
                                }) {
                                    Circle().fill(Color.red).frame(width: 20, height: 20)
                                }
                                .position(x: station.x, y: station.y)
                            }
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Game ID: \(gameID.prefix(6))")
                        Text("Team: \(teamID)")
                        if !otherTeamIDs.isEmpty {
                            Text("Other: \(otherTeamIDs.joined(separator: ", "))")
                        }
                    }.padding(.leading, 12).padding(.top, 40)
                }
                .frame(height: UIScreen.main.bounds.height * 0.5)

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if !unlockedChallenges.isEmpty {
                            Text("🔓 Active Challenges")
                            ForEach(unlockedChallenges) { challenge in
                                Button(action: { selectedChallenge = challenge }) {
                                    VStack(alignment: .leading) {
                                        Text(challenge.title).bold()
                                        Text("📍 \(challenge.station)")
                                    }
                                }
                                .padding().background(Color.gray.opacity(0.1)).cornerRadius(10)
                            }
                        }

                        if !completedChallenges.isEmpty {
                            Text("✅ Completed Challenges")
                            ForEach(completedChallenges) { challenge in
                                VStack(alignment: .leading) {
                                    Text(challenge.title).strikethrough()
                                    Text("📍 \(challenge.station)")
                                }
                                .padding().background(Color.gray.opacity(0.2)).cornerRadius(10)
                            }
                        }

                        let otherChallenges = otherTeamsUnlocked
                            .flatMap { (teamID, list) in list.map { (teamID, $0) } }
                            .filter { (tid, ch) in
                                !unlockedChallenges.contains(where: { $0.title == ch.title && $0.station == ch.station })
                            }

                        if !otherChallenges.isEmpty {
                            Text("👀 Challenges Unlocked by Other Teams")
                            ForEach(otherChallenges, id: \.1.id) { (teamID, challenge) in
                                VStack(alignment: .leading) {
                                    Text(challenge.title)
                                    Text("📍 \(challenge.station)")
                                    Text("By: \(teamID)")
                                }
                                .padding().background(Color.orange.opacity(0.1)).cornerRadius(10)
                            }
                        }
                    }.padding()
                }
            }
            .onAppear {
                print("🧠 MainGameScreenView appeared: gameID=\(gameID), teamID=\(teamID)")
                listenForUnlockedChallenges()
                listenForCompletedChallenges()
                listenForOtherTeams()
            }
            .fullScreenCover(item: $selectedStation) { station in
                StationPopupFullScreenView(
                    station: station,
                    onUnlock: { unlockChallenge(for: station) },
                    onClose: { selectedStation = nil },
                    alreadyUnlocked: unlockedChallenges.contains { $0.station == station.name }
                )
            }
            .fullScreenCover(item: $selectedChallenge) { challenge in
                ChallengePopupView(
                    challenge: challenge,
                    onComplete: {
                        completeChallenge(challenge)
                        selectedChallenge = nil
                    },
                    onClose: { selectedChallenge = nil }
                )
            }
        }
    }

    func unlockChallenge(for station: Station) {
        guard !unlockedChallenges.contains(where: { $0.station == station.name }) else { return }
        guard let challenge = sampleChallenges.filter({ $0.station == station.name }).randomElement() else { return }

        let data: [String: Any] = [
            "title": challenge.title,
            "description": challenge.description,
            "station": challenge.station,
            "timestamp": Timestamp()
        ]

        Firestore.firestore().collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("unlockedChallenges")
            .addDocument(data: data)

        print("🆕 Unlocked new challenge at \(station.name): \(challenge.title)")
    }

    func completeChallenge(_ challenge: GameChallenge) {
        unlockedChallenges.removeAll { $0.id == challenge.id }
        completedChallenges.append(challenge)

        let data: [String: Any] = [
            "title": challenge.title,
            "description": challenge.description,
            "station": challenge.station,
            "timestamp": Timestamp()
        ]

        Firestore.firestore().collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("completedChallenges")
            .addDocument(data: data)

        print("✅ Completed challenge: \(challenge.title)")
    }

    func listenForUnlockedChallenges() {
        Firestore.firestore().collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("unlockedChallenges")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.unlockedChallenges = docs.map {
                    let d = $0.data()
                    return GameChallenge(
                        title: d["title"] as? String ?? "",
                        description: d["description"] as? String ?? "",
                        station: d["station"] as? String ?? ""
                    )
                }
                print("📡 Synced \(self.unlockedChallenges.count) unlocked challenges for own team")
            }
    }

    func listenForCompletedChallenges() {
        Firestore.firestore().collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("completedChallenges")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.completedChallenges = docs.map {
                    let d = $0.data()
                    return GameChallenge(
                        title: d["title"] as? String ?? "",
                        description: d["description"] as? String ?? "",
                        station: d["station"] as? String ?? ""
                    )
                }
            }
    }

    func listenForOtherTeams() {
        let db = Firestore.firestore()
        let teamCollection = db.collection("games").document(gameID).collection("teams")

        print("👂 Listening for teams in game \(gameID)")

        // 1. Fetch existing teams immediately
        teamCollection.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching teams: \(error.localizedDescription)")
                return
            }

            guard let docs = snapshot?.documents else {
                print("⚠️ No teams found in initial fetch.")
                return
            }

            let allTeamIDs = docs.map { $0.documentID }
            print("📦 (Initial fetch) All team IDs: \(allTeamIDs)")

            let others = allTeamIDs.filter { $0 != teamID }
            self.otherTeamIDs = others
            print("👥 (Initial fetch) Other team IDs: \(others)")

            for id in others {
                self.attachListenerToTeam(id)
            }
        }

        // 2. Live updates for future team changes
        teamCollection.addSnapshotListener { snapshot, error in
            if let error = error {
                print("❌ Live team update error: \(error.localizedDescription)")
                return
            }

            guard let docs = snapshot?.documents else {
                print("⚠️ No teams found during live update.")
                return
            }

            let allTeamIDs = docs.map { $0.documentID }
            let others = allTeamIDs.filter { $0 != teamID }

            self.otherTeamIDs = others
            print("📦 (Live update) All team IDs: \(allTeamIDs)")
            print("👥 (Live update) Other team IDs: \(others)")

            for id in others {
                self.attachListenerToTeam(id)
            }
        }
    }

    func attachListenerToTeam(_ id: String) {
        guard !attachedListeners.contains(id) else { return }

        let db = Firestore.firestore()
        attachedListeners.insert(id)

        print("📡 Listening to team \(id)'s unlockedChallenges")

        db.collection("games").document(gameID)
            .collection("teams").document(id)
            .collection("unlockedChallenges")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else {
                    print("⚠️ No challenges found for team \(id)")
                    return
                }

                let challenges = docs.map { doc in
                    let data = doc.data()
                    return GameChallenge(
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        station: data["station"] as? String ?? ""
                    )
                }

                DispatchQueue.main.async {
                    self.otherTeamsUnlocked[id] = challenges
                    print("📥 Synced \(challenges.count) from \(id)")
                }
            }
    }

}
