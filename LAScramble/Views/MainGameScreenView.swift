import SwiftUI
import FirebaseFirestore

struct MainGameScreenView: View {
    var gameID: String
    var teamID: String

    // MARK: - State Variables
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
    @State private var showSidebar = false

    @State private var timeRemaining: TimeInterval = 0
    @State private var timerEnded = false

    let gameDuration: TimeInterval = 20 // 2 hours in seconds

    @State private var timer: Timer?
    
    var body: some View {
        Group {
            if gameID.isEmpty || teamID.isEmpty {
                VStack {
                    Text("❌ Error: Game ID or Team ID missing.")
                    Text("gameID=\(gameID), teamID=\(teamID)")
                }
            } else {
                mainGameContent
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
            fetchStartTimeAndBeginTimer()
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
        .sheet(isPresented: $showSidebar) {
            SidebarMenuView(gameID: gameID, teamID: teamID, teamNames: teamNames)
        }
        .fullScreenCover(isPresented: $timerEnded) {
            EndGameView(gameID: gameID)
        }
    }

    // MARK: - Main Game UI Extracted to Reduce Complexity
    private var mainGameContent: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text("👥 \(teamName)").font(.headline)
                    Text("⏳ \(formatTime(timeRemaining))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: { showSidebar.toggle() }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .padding()
                }
            }
            .padding(.horizontal)


            ScoreboardHeaderView(teamLineCounts: teamLineCounts, teamNames: teamNames) {
                showScoreDetails = true
            }

            metroMapView
            Divider()
            challengeListView
        }
    }

    private var metroMapView: some View {
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
                                .fill(isCompletedGlobally ? Color.gray : (station.lines.first?.color ?? .black))
                                .frame(width: 20, height: 20)
                        }
                        .disabled(isCompletedGlobally)
                        .position(x: station.x, y: station.y)
                    }
                }
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.5)
    }

    private var challengeListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // 🔓 Active Challenges
                let activeChallenges = unlockedChallenges.filter { challenge in
                    !globallyCompleted.contains(where: {
                        $0.title == challenge.title && $0.station == challenge.station
                    })
                }

                if !activeChallenges.isEmpty {
                    Text("🔓 Active Challenges").font(.headline)
                    ForEach(activeChallenges) { challenge in
                        Button(action: { selectedChallenge = challenge }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(challenge.title).bold()
                                Text("📍 \(challenge.station)")
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }

                // ✅ Completed Challenges
                if !completedChallenges.isEmpty {
                    Text("✅ Completed Challenges").font(.headline)
                    ForEach(completedChallenges) { challenge in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(challenge.title).strikethrough()
                            Text("📍 \(challenge.station)")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                }

                // 👀 Challenges Unlocked by Other Teams
                let others = otherTeamsUnlocked
                    .flatMap { (teamID, list) in list.map { (teamID, $0) } }
                    .filter { (_, ch) in
                        !unlockedChallenges.contains { $0.title == ch.title && $0.station == ch.station } &&
                        !globallyCompleted.contains { $0.title == ch.title && $0.station == ch.station }
                    }

                if !others.isEmpty {
                    Text("👀 Challenges Unlocked by Other Teams").font(.headline)
                    ForEach(others, id: \.1.id) { (tid, ch) in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ch.title)
                            Text("📍 \(ch.station)")
                            Text("By: \(teamNames[tid] ?? tid)")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }
                }

                // 🔒 Completed by Other Teams
                let completedByOthers = globallyCompleted.filter {
                    !completedChallenges.contains($0)
                }

                if !completedByOthers.isEmpty {
                    Text("🔒 Completed by Other Teams").font(.headline)
                    ForEach(completedByOthers) { challenge in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(challenge.title).strikethrough()
                            Text("📍 \(challenge.station)")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
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

                        // ✅ Force team name re-fetch
                        fetchTeamNames()
                    }
                }
            }
        }
    }



    // ... other functions (unlockChallenge, completeChallenge, listeners) remain unchanged ...


    func unlockChallenge(for station: Station, on line: MetroLine) {
        print("🚀 Attempting to unlock challenge for station: \(station.name)")

        let db = Firestore.firestore()
        let safeStationID = station.name.replacingOccurrences(of: "/", with: "_")
        let stationRef = db.collection("games").document(gameID)
            .collection("stationChallenges").document(safeStationID)

        stationRef.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let title = data["title"] as? String,
               let description = data["description"] as? String,
               let stationName = data["station"] as? String,
               let lineRaw = data["line"] as? String,
               let line = MetroLine(rawValue: lineRaw) {

                print("📌 Found existing global challenge for \(stationName): \(title)")
                let challenge = GameChallenge(title: title, description: description, station: stationName, line: line)
                self.saveChallengeToUnlocked(challenge)

            } else {
                let options = sampleChallenges.filter { $0.station == station.name }
                guard let random = options.randomElement() else {
                    print("❌ No challenges found for station: \(station.name)")
                    return
                }

                let chosenChallenge = GameChallenge(title: random.title, description: random.description, station: station.name, line: line)

                let data: [String: Any] = [
                    "title": chosenChallenge.title,
                    "description": chosenChallenge.description,
                    "station": chosenChallenge.station,
                    "line": chosenChallenge.line?.rawValue ?? "",
                    "timestamp": Timestamp()
                ]

                stationRef.setData(data) { err in
                    if let err = err {
                        print("❌ Failed to save global station challenge: \(err.localizedDescription)")
                    } else {
                        print("🌍 Global station challenge set for \(station.name): \(chosenChallenge.title)")
                        self.saveChallengeToUnlocked(chosenChallenge)
                    }
                }
            }
        }
    }


    func saveChallengeToUnlocked(_ challenge: GameChallenge) {
        let data: [String: Any] = [
            "title": challenge.title,
            "description": challenge.description,
            "station": challenge.station,
            "line": challenge.line?.rawValue ?? "",
            "timestamp": Timestamp()
        ]

        Firestore.firestore().collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("unlockedChallenges")
            .addDocument(data: data)

        print("✅ Challenge '\(challenge.title)' added to unlockedChallenges for team \(teamID)")
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
        
        fetchTeamNames()
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
        let db = Firestore.firestore()
        db.collection("games").document(gameID).collection("teams").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            var names: [String: String] = [:]
            for doc in docs {
                let teamID = doc.documentID
                if let name = doc.data()["teamName"] as? String {
                    names[teamID] = name
                }
            }

            DispatchQueue.main.async {
                self.teamNames = names
            }
        }
    }

    func fetchStartTimeAndBeginTimer() {
        let gameRef = Firestore.firestore().collection("games").document(gameID)
        gameRef.getDocument { snapshot, _ in
            guard let data = snapshot?.data(),
                  let timestamp = data["startTime"] as? Timestamp else { return }

            let startTime = timestamp.dateValue()
            let endTime = startTime.addingTimeInterval(gameDuration)

            updateRemainingTime(endTime: endTime)

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateRemainingTime(endTime: endTime)
            }
        }
    }

    func updateRemainingTime(endTime: Date) {
        let remaining = endTime.timeIntervalSinceNow
        DispatchQueue.main.async {
            self.timeRemaining = max(0, remaining)
            self.timerEnded = remaining <= 0
        }
    }

    func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}


