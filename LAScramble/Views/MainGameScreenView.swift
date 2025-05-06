import SwiftUI
import FirebaseFirestore

struct MainGameScreenView: View {
    var gameID: String
    var teamID: String

    @State private var selectedStation: Station?
    @State private var selectedChallenge: GameChallenge?
    @State private var unlockedChallenges: [GameChallenge] = []
    @State private var completedChallenges: [GameChallenge] = []
    @State private var globallyCompleted: [GameChallenge] = []
    @State private var otherTeamsUnlocked: [String: [GameChallenge]] = [:]
    @State private var otherTeamIDs: [String] = []
    @State private var attachedListeners: Set<String> = []
    
    @State private var teamLineCounts: [String: [MetroLine: Int]] = [:]
    @State private var showScoreDetails = false
    @State private var teamName: String = ""
    @State private var teamNames: [String: String] = [:]


    var body: some View {
        if gameID.isEmpty || teamID.isEmpty {
            VStack {
                Text("❌ Error: Game ID or Team ID missing.")
                Text("gameID=\(gameID), teamID=\(teamID)")
            }
        } else {
            VStack(spacing: 0) {
                HStack {
                    Text("👥 \(teamName)")
                        .font(.headline)
                        .padding(.leading)
                    Spacer()
                }
                ScoreboardHeaderView(teamLineCounts: teamLineCounts, teamNames: teamNames) {
                    showScoreDetails = true
                }

                ZStack(alignment: .topLeading) {
                    GeometryReader { geometry in
                        ZStack {
                            Image("metro_map")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width, height: geometry.size.height)

                            ForEach(sampleStations) { station in
                                let isCompletedGlobally = globallyCompleted.contains { $0.station == station.name }

                                Button(action: {
                                    selectedStation = station
                                }) {
                                    Circle()
                                        .fill(
                                            isCompletedGlobally ? Color.gray : (station.lines.first?.color ?? .black)
                                        )
                                        .frame(width: 20, height: 20)
                                }
                                .disabled(isCompletedGlobally)
                                .position(x: station.x, y: station.y)
                            }
                        }
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.5)

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if !unlockedChallenges.isEmpty {
                            Text("🔓 Active Challenges")
                            ForEach(unlockedChallenges.filter { challenge in
                                !globallyCompleted.contains(where: {
                                    $0.title == challenge.title && $0.station == challenge.station
                                })
                            }) { challenge in
                                Button(action: { selectedChallenge = challenge }) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(challenge.title).bold()
                                        Text("📍 \(challenge.station)")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                        }

                        if !completedChallenges.isEmpty {
                            Text("✅ Completed Challenges")
                            ForEach(completedChallenges) { challenge in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(challenge.title).strikethrough()
                                    Text("📍 \(challenge.station)")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                        }

                        let otherChallenges = otherTeamsUnlocked
                            .flatMap { (teamID, list) in list.map { (teamID, $0) } }
                            .filter { (tid, ch) in
                                !unlockedChallenges.contains(where: { $0.title == ch.title && $0.station == ch.station }) &&
                                !globallyCompleted.contains(where: { $0.title == ch.title && $0.station == ch.station })
                            }

                        if !otherChallenges.isEmpty {
                            Text("👀 Challenges Unlocked by Other Teams")
                            ForEach(otherChallenges, id: \.1.id) { (teamID, challenge) in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(challenge.title)
                                    Text("📍 \(challenge.station)")
                                    Text("By: \(teamID)")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }

                        if !globallyCompleted.filter({ !completedChallenges.contains($0) }).isEmpty {
                            Text("🔒 Completed by Other Teams")
                            ForEach(globallyCompleted.filter { !completedChallenges.contains($0) }) { challenge in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(challenge.title).strikethrough()
                                    Text("📍 \(challenge.station)")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }.padding()
                }
            }
            .onAppear {
                listenForUnlockedChallenges()
                listenForCompletedChallenges()
                listenForOtherTeams()
                listenForGlobalCompletions()
                updateLineControlScores()
                listenToAllCompletedChallenges()
                fetchTeamName()
                fetchTeamNames()
            }
            .fullScreenCover(item: $selectedStation) { station in
                StationPopupFullScreenView(
                    station: station,
                    onUnlock: { selectedLine in
                        unlockChallenge(for: station, on: selectedLine)
                    },
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
            .sheet(isPresented: $showScoreDetails) {
                ScoreDetailsView(teamLineCounts: teamLineCounts, teamNames: teamNames)
            }
        }
    }

    func updateLineControlScores() {
        let db = Firestore.firestore()
        let teamsRef = db.collection("games").document(gameID).collection("teams")

        teamsRef.getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }

            var counts: [String: [MetroLine: Set<String>]] = [:]

            for doc in docs {
                let teamID = doc.documentID
                let completedRef = teamsRef.document(teamID).collection("completedChallenges")

                completedRef.getDocuments { snap, _ in
                    guard let challengeDocs = snap?.documents else { return }

                    for c in challengeDocs {
                        let station = c.data()["station"] as? String ?? ""
                        let lineRaw = c.data()["line"] as? String ?? ""
                        if let line = MetroLine(rawValue: lineRaw) {
                            counts[teamID, default: [:]][line, default: []].insert(station)
                        }
                    }

                    DispatchQueue.main.async {
                        // Convert station sets to counts
                        var lineCounts: [String: [MetroLine: Int]] = [:]
                        for (team, lines) in counts {
                            for (line, stations) in lines {
                                lineCounts[team, default: [:]][line] = stations.count
                            }
                        }
                        self.teamLineCounts = lineCounts
                    }
                }
            }
        }
    }


    // ... other functions (unlockChallenge, completeChallenge, listeners) remain unchanged ...


    func unlockChallenge(for station: Station, on line: MetroLine) {
        guard !unlockedChallenges.contains(where: { $0.station == station.name }) else { return }
        guard let challenge = sampleChallenges.filter({ $0.station == station.name }).randomElement() else { return }

        let data: [String: Any] = [
            "title": challenge.title,
            "description": challenge.description,
            "station": challenge.station,
            "line": line.rawValue,
            "timestamp": Timestamp()
        ]

        Firestore.firestore().collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("unlockedChallenges")
            .addDocument(data: data)

        print("🆕 Unlocked \(challenge.title) at \(station.name) on Line \(line.rawValue)")
    }


    func completeChallenge(_ challenge: GameChallenge) {
        unlockedChallenges.removeAll { $0.id == challenge.id }
        completedChallenges.append(challenge)

        let data: [String: Any] = [
            "title": challenge.title,
            "description": challenge.description,
            "station": challenge.station,
            "line": challenge.line?.rawValue ?? "",
            "timestamp": Timestamp()
        ]

        let gameRef = Firestore.firestore().collection("games").document(gameID)
        gameRef.collection("teams").document(teamID)
            .collection("completedChallenges").addDocument(data: data)

        gameRef.collection("completedChallenges").addDocument(data: data)

        print("✅ Completed challenge: \(challenge.title)")

        // ✅ Force refresh line control scoring
        updateLineControlScores()
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
                        station: d["station"] as? String ?? "",
                        line: MetroLine(rawValue: d["line"] as? String ?? "")
                    )
                }
            }
    }

    func listenToAllCompletedChallenges() {
        let teamsRef = Firestore.firestore()
            .collection("games").document(gameID)
            .collection("teams")

        teamsRef.addSnapshotListener { snapshot, _ in
            guard let docs = snapshot?.documents else { return }

            for doc in docs {
                let teamID = doc.documentID
                teamsRef.document(teamID)
                    .collection("completedChallenges")
                    .addSnapshotListener { _, _ in
                        updateLineControlScores() // Refresh scoreboard when any team completes something
                    }
            }
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
                        station: d["station"] as? String ?? "",
                        line: MetroLine(rawValue: d["line"] as? String ?? "")
                    )

                }
            }
    }

    func listenForGlobalCompletions() {
        Firestore.firestore().collection("games").document(gameID)
            .collection("completedChallenges")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.globallyCompleted = docs.map {
                    let d = $0.data()
                    return GameChallenge(
                        title: d["title"] as? String ?? "",
                        description: d["description"] as? String ?? "",
                        station: d["station"] as? String ?? "",
                        line: MetroLine(rawValue: d["line"] as? String ?? "")
                    )
                }
                print("🌍 Global completions updated: \(self.globallyCompleted.count)")
            }
    }

    func listenForOtherTeams() {
        let db = Firestore.firestore()
        let teamCollection = db.collection("games").document(gameID).collection("teams")

        teamCollection.getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            let others = docs.map { $0.documentID }.filter { $0 != teamID }
            self.otherTeamIDs = others
            for id in others { self.attachListenerToTeam(id) }
        }

        teamCollection.addSnapshotListener { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            let others = docs.map { $0.documentID }.filter { $0 != teamID }
            self.otherTeamIDs = others
            for id in others { self.attachListenerToTeam(id) }
        }
    }

    func attachListenerToTeam(_ id: String) {
        guard !attachedListeners.contains(id) else { return }
        attachedListeners.insert(id)

        Firestore.firestore().collection("games").document(gameID)
            .collection("teams").document(id)
            .collection("unlockedChallenges")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                let challenges = docs.map {
                    let d = $0.data()
                    return GameChallenge(
                        title: d["title"] as? String ?? "",
                        description: d["description"] as? String ?? "",
                        station: d["station"] as? String ?? "",
                        line: MetroLine(rawValue: d["line"] as? String ?? "")
                    )
                }
                self.otherTeamsUnlocked[id] = challenges
            }
    }
    func fetchTeamName() {
        let db = Firestore.firestore()
        db.collection("games").document(gameID)
            .collection("teams").document(teamID)
            .getDocument { snapshot, error in
                if let data = snapshot?.data(), let name = data["teamName"] as? String {
                    self.teamName = name
                }
            }
    }
    func fetchTeamNames() {
        Firestore.firestore().collection("games").document(gameID).collection("teams").getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            var names: [String: String] = [:]
            for doc in docs {
                if let name = doc.data()["teamName"] as? String {
                    names[doc.documentID] = name
                }
            }
            self.teamNames = names
        }
    }


}
