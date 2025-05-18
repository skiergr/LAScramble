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
    let gameDuration: TimeInterval = 2*60*60;
    @State private var timer: Timer?
   
    @State private var selectedLine: MetroLine?
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var sacrificedStations: Set<String> = []
    @State private var sacrificedLineLocks: [MetroLine: Date] = [:]
    @State private var sacrificedChallenges: [GameChallenge] = []
    
    var body: some View {
        Group {
            if gameID.isEmpty || teamID.isEmpty {
                errorView
            } else {
                mainGameContent
            }
        }
        .onAppear(perform: setupListeners)
        .fullScreenCover(item: $selectedStation, content: stationPopup)
        .fullScreenCover(item: $selectedChallenge) { challenge in
            challengePopup(challenge: challenge)
        }
        .sheet(isPresented: $showScoreDetails) {
            ScoreDetailsView(teamLineCounts: teamLineCounts, teamNames: teamNames)
        }
        .sheet(isPresented: $showSidebar) {
            SidebarMenuView(
                gameID: gameID,
                teamID: teamID,
                teamNames: teamNames,
                teamLineCounts: teamLineCounts
            )
        }
        .fullScreenCover(isPresented: $timerEnded) {
            EndGameView(gameID: gameID)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Limit Reached"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Components

    private var errorView: some View {
        VStack {
            Text("Error: Game ID or Team ID missing.")
            Text("gameID=\(gameID), teamID=\(teamID)")
        }
    }

    private func stationPopup(station: Station) -> some View {
        let line = selectedLine ?? station.lines.first!

        return StationPopupFullScreenView(
            station: station,
            onUnlock: { selectedLine in
                unlockChallenge(for: station, on: selectedLine)
                selectedStation = nil
            },
            onClose: {
                selectedStation = nil
                selectedLine = nil
            },
            isSacrificed: sacrificedStations.contains(station.name),
            controllingTeamName: controllingTeamForStation(station),
            teamNames: teamNames,
            myTeamID: teamID,
            selectedLine: line,
            allUnlocked: unlockedChallenges,
            allCompleted: completedChallenges,
            globalCompleted: globallyCompleted,
            allOtherUnlocked: otherTeamsUnlocked,
            teamCompletions: allTeamCompletions
        )
    }
    
    private func challengePopup(challenge: GameChallenge) -> some View {
        ChallengePopupView(
            challenge: challenge,
            onComplete: {
                completeChallenge(challenge)
                selectedChallenge = nil
            },
            onSacrifice: {
                sacrificeChallenge(challenge)
                selectedChallenge = nil
            },
            onClose: { selectedChallenge = nil }
        )
    }

    private func setupListeners() {
        listenForUnlockedChallenges()
        listenForCompletedChallenges()
        listenForOtherTeams()
        listenForGlobalCompletions()
        updateLineControlScores()
        listenToAllCompletedChallenges()
        listenForSacrifices()
        fetchTeamName()
        fetchTeamNames()
        fetchStartTimeAndBeginTimer()
        startLineControlListener()
    }


    // MARK: - Main Game UI Extracted to Reduce Complexity
    private var mainGameContent: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(teamName)").font(.headline)
                    Text("\(formatTime(timeRemaining))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                if let lockedLine = sacrificedLineLocks.first(where: { $0.value > Date() }) {
                    Spacer()
                    let minutesLeft = Int(lockedLine.value.timeIntervalSinceNow) / 60
                    Text("Line \(lockedLine.key.rawValue) locked for \(minutesLeft)m")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                Spacer()
                Button(action: { showSidebar.toggle() }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .padding()
                }
            }
            .padding(.horizontal)


            ScoreboardHeaderView(controlledLineCounts: controlledLineCounts, teamNames: teamNames) {
                showScoreDetails = true
            }

            metroMapView
            Divider()
            challengeListView
        }
    }

    private var metroMapView: some View {
        ZStack {
            ZoomableScrollView {
                ZStack {
                    Image("metro_map")
                        .resizable()
                        .scaledToFit()

                    ForEach(sampleStations) { station in
                        Button(action: {
                            selectedLine = station.lines.first
                            selectedStation = station
                        }) {
                            StationDotView(
                                station: station,
                                globallyCompleted: globallyCompleted,
                                sacrificedStations: sacrificedStations,
                                completedChallenges: completedChallenges,
                                sacrificedLineLocks: sacrificedLineLocks,
                                teamID: teamID,
                                allTeamCompletions: allTeamCompletions
                            )

                        }
                        .position(x: station.x, y: station.y)
                    }
                }
            }
            .clipped()
        }
        .frame(height: UIScreen.main.bounds.height * 0.35)
    }

    struct ZoomableScrollView<Content: View>: View {
        @State private var scale: CGFloat = 1.0
        @State private var lastScale: CGFloat = 1.0
        @State private var offset: CGSize = .zero
        @State private var lastOffset: CGSize = .zero

        private let minScale: CGFloat = 1.0
        private let maxScale: CGFloat = 3.0

        let content: Content

        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }

        var body: some View {
            GeometryReader { geometry in
                let containerSize = geometry.size

                content
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let newScale = lastScale * value
                                    scale = min(max(newScale, minScale), maxScale)
                                }
                                .onEnded { _ in
                                    scale = min(max(scale, minScale), maxScale)
                                    lastScale = scale
                                    offset = clampedOffset(in: containerSize)
                                    lastOffset = offset
                                },
                            DragGesture()
                                .onChanged { value in
                                    guard scale > 1.0 else { return }
                                    let proposedOffset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                    offset = clampedOffset(proposedOffset, in: containerSize)
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                    )
                    .animation(.easeInOut(duration: 0.2), value: scale)
            }
        }

        // MARK: - Clamping Helper
        private func clampedOffset(_ proposed: CGSize? = nil, in containerSize: CGSize) -> CGSize {
            let proposedOffset = proposed ?? offset

            let contentWidth = containerSize.width * scale
            let contentHeight = containerSize.height * scale

            let maxX = max((contentWidth - containerSize.width) / 2, 0)
            let maxY = max((contentHeight - containerSize.height) / 2, 0)

            let clampedX = min(max(proposedOffset.width, -maxX), maxX)
            let clampedY = min(max(proposedOffset.height, -maxY), maxY)

            return CGSize(width: clampedX, height: clampedY)
        }
    }

    private var challengeListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Active Challenges
                let activeChallenges = unlockedChallenges.filter { challenge in
                    !globallyCompleted.contains(where: {
                        $0.title == challenge.title && $0.station == challenge.station
                    }) && !sacrificedStations.contains(challenge.station)
                }

                if !activeChallenges.isEmpty {
                    Text("Active Challenges").font(.headline)
                    ForEach(activeChallenges) { challenge in
                        Button(action: { selectedChallenge = challenge }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(challenge.title).bold()
                                Text("\(challenge.station)")
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }

                // Completed Challenges
                if !completedChallenges.isEmpty {
                    Text("Completed Challenges").font(.headline)
                    ForEach(completedChallenges) { challenge in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(challenge.title).strikethrough()
                            Text("\(challenge.station)")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                }

                // Challenges Unlocked by Other Teams
                let others = otherTeamsUnlocked
                    .flatMap { (teamID, list) in list.map { (teamID, $0) } }
                    .filter { (_, ch) in
                        !unlockedChallenges.contains { $0.title == ch.title && $0.station == ch.station } &&
                        !globallyCompleted.contains { $0.title == ch.title && $0.station == ch.station }
                    }

                if !others.isEmpty {
                    Text("Challenges Unlocked by Other Teams").font(.headline)
                    ForEach(others, id: \.1.id) { (tid, ch) in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ch.title)
                            Text("\(ch.station)")
                            Text("By: \(teamNames[tid] ?? tid)")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }
                }

                // Completed by Other Teams
                let completedByOthers = globallyCompleted.filter {
                    !completedChallenges.contains($0)
                }

                if !completedByOthers.isEmpty {
                    Text("Completed by Other Teams").font(.headline)
                    ForEach(completedByOthers) { challenge in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(challenge.title).strikethrough()
                            Text("\(challenge.station)")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                }

                // Sacrificed Challenges
                if !sacrificedChallenges.isEmpty {
                    Text("Sacrificed Challenges").font(.headline)
                    ForEach(sacrificedChallenges) { challenge in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(challenge.title).italic()
                            Text("\(challenge.station) (Unavailable)")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.05))
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

                        // Force team name re-fetch
                        fetchTeamNames()
                    }
                }
            }
        }
    }

    func unlockChallenge(for station: Station, on line: MetroLine) {
        if sacrificedStations.contains(station.name) {
            alertMessage = "You sacrificed this station and can’t unlock it again."
            selectedStation = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showAlert = true
            }
            return
        }

        if let lockUntil = sacrificedLineLocks[line], lockUntil > Date() {
            let minutes = Int(lockUntil.timeIntervalSinceNow) / 60
            alertMessage = "You sacrificed a challenge on this line. Try again in \(minutes) minutes."
            selectedStation = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showAlert = true
            }
            return
        }

        print("Attempting to unlock challenge for station: \(station.name) on line \(line.rawValue)")

        let db = Firestore.firestore()

        // Use both station + line in the global ID
        let safeStationLineID = "\(station.name)_\(line.rawValue)"
            .replacingOccurrences(of: "[^a-zA-Z0-9_]+", with: "_", options: .regularExpression)
        
        let stationRef = db.collection("games").document(gameID)
            .collection("stationChallenges").document(safeStationLineID)
        
        let activeUnlocked = unlockedChallenges.filter { challenge in
            !sacrificedStations.contains(challenge.station) &&
            !globallyCompleted.contains(where: {
                $0.station == challenge.station && $0.title == challenge.title && $0.line == challenge.line
            })
        }

        if activeUnlocked.count >= 2 {
            selectedStation = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                alertMessage = "You already have 2 active challenges. Complete one before unlocking another."
                showAlert = true
            }
            return
        }

        stationRef.getDocument { snapshot, error in
            guard error == nil else {
                print("❌ Firestore error: \(error!.localizedDescription)")
                return
            }

            if let snapshot = snapshot, snapshot.exists,
               let data = snapshot.data(),
               let title = data["title"] as? String,
               let description = data["description"] as? String,
               let stationName = data["station"] as? String,
               let lineRaw = data["line"] as? String,
               let globalLine = MetroLine(rawValue: lineRaw) {

                let challenge = GameChallenge(title: title, description: description, station: stationName, line: globalLine)

                let isCompletedGlobally = globallyCompleted.contains {
                    $0.title == challenge.title && $0.station == station.name && $0.line == line
                }

                guard !isCompletedGlobally else {
                    print("Challenge '\(challenge.title)' already completed at \(station.name) on line \(line.rawValue)")
                    return
                }

                print("Found existing challenge: \(challenge.title)")
                self.saveChallengeToUnlocked(challenge)

            } else {
                // Document doesn't exist — fallback to random challenge
                print("📄 No existing station challenge found for \(station.name) on \(line.rawValue) — selecting random.")

                let options = sampleChallenges.filter { $0.station == station.name && $0.line == line }

                guard let random = options.randomElement() else {
                    print("❌ No challenges available for station: \(station.name) on \(line.rawValue)")
                    return
                }

                let chosenChallenge = GameChallenge(
                    title: random.title,
                    description: random.description,
                    station: random.station,
                    line: line
                )

                let data: [String: Any] = [
                    "title": chosenChallenge.title,
                    "description": chosenChallenge.description,
                    "station": chosenChallenge.station,
                    "line": chosenChallenge.line?.rawValue ?? "",
                    "timestamp": Timestamp()
                ]

                stationRef.setData(data) { err in
                    if let err = err {
                        print("Failed to save global challenge: \(err.localizedDescription)")
                    } else {
                        print("✅ Global challenge set for \(station.name) on line \(line.rawValue): \(chosenChallenge.title)")
                        self.saveChallengeToUnlocked(chosenChallenge)
                    }
                }
            }
        }
    }

    func saveChallengeToUnlocked(_ challenge: GameChallenge, sacrificed: Bool = false) {
        let data: [String: Any] = [
            "title": challenge.title,
            "description": challenge.description,
            "station": challenge.station,
            "line": challenge.line?.rawValue ?? "",
            "timestamp": Timestamp(),
            "sacrificed": sacrificed // ✅
        ]

        let teamRef = Firestore.firestore()
            .collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("unlockedChallenges")

        let rawID = "\(challenge.station)_\(challenge.title)_\(challenge.line?.rawValue ?? "")"
        let docID = rawID
            .replacingOccurrences(of: "[^a-zA-Z0-9_]+", with: "_", options: .regularExpression)
            .replacingOccurrences(of: "_+", with: "_") // Optional cleanup
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))

        teamRef.document(docID).setData(data) { error in
            if let error = error {
                print("❌ Failed to set unlocked challenge: \(error.localizedDescription)")
            } else {
                print("✅ Challenge saved to unlockedChallenges under \(docID)")
            }
        }

        print("✅ Challenge '\(challenge.title)' added to unlockedChallenges for team \(teamID)")
    }


    func completeChallenge(_ challenge: GameChallenge) {
        if sacrificedStations.contains(challenge.station) {
            alertMessage = "You sacrificed this station. You cannot complete its challenge."
            showAlert = true
            return
        }

        if let line = challenge.line,
           let lockUntil = sacrificedLineLocks[line],
           lockUntil > Date() {
            let minutes = Int(lockUntil.timeIntervalSinceNow) / 60
            alertMessage = "This line is locked due to a sacrifice. Try again in \(minutes) minute(s)."
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showAlert = true
            }
            return
        }

        // ✅ Remove from unlockedChallenges
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
    
    @State private var allTeamCompletions: [String: [GameChallenge]] = [:]


    func listenToAllCompletedChallenges() {
        let teamsRef = Firestore.firestore()
            .collection("games").document(gameID)
            .collection("teams")

        teamsRef.getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }

            for doc in docs {
                let teamID = doc.documentID
                teamsRef.document(teamID)
                    .collection("completedChallenges")
                    .addSnapshotListener { snap, _ in
                        guard let docs = snap?.documents else { return }

                        let challenges = docs.map { d in
                            let data = d.data()
                            return GameChallenge(
                                title: data["title"] as? String ?? "",
                                description: data["description"] as? String ?? "",
                                station: data["station"] as? String ?? "",
                                line: MetroLine(rawValue: data["line"] as? String ?? "")
                            )
                        }

                        DispatchQueue.main.async {
                            allTeamCompletions[teamID] = challenges
                        }
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
                print("Global completions updated: \(self.globallyCompleted.count)")
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
    func controllingTeamForStation(_ station: Station) -> String? {
        guard let line = station.lines.first else { return nil }

        let maxCount = teamLineCounts.values.map { $0[line] ?? 0 }.max() ?? 0
        let topTeams = teamLineCounts.filter { $0.value[line] == maxCount }

        if topTeams.count == 1 {
            let teamID = topTeams.first!.key
            return teamNames[teamID]
        }
        return nil // tie or no control
    }
    func teamThatCompleted(_ challenge: GameChallenge) -> String? {
        for (tid, challenges) in allTeamCompletions {
            if challenges.contains(where: {
                $0.title == challenge.title && $0.station == challenge.station
            }) {
                return tid
            }
        }
        return nil
    }
    
    struct StationDotView: View {
        let station: Station
        let globallyCompleted: [GameChallenge]
        let sacrificedStations: Set<String>
        let completedChallenges: [GameChallenge]
        let sacrificedLineLocks: [MetroLine: Date]
        let teamID: String
        let allTeamCompletions: [String: [GameChallenge]]

        var body: some View {
            ZStack {
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    let center = CGPoint(x: size / 2, y: size / 2)
                    let radius = size / 2

                    if sacrificedStations.contains(station.name) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: size, height: size)
                            .overlay(Text("✖").font(.caption).bold().foregroundColor(.white))
                    } else {
                        ForEach(Array(station.lines.enumerated()), id: \.offset) { index, line in
                            let isCompletedBySelf = completedChallenges.contains {
                                $0.station == station.name && $0.line == line
                            }
                            let isCompletedGlobally = globallyCompleted.contains {
                                $0.station == station.name && $0.line == line
                            }
                            let isCompletedByOtherTeam = isCompletedGlobally && !isCompletedBySelf
                            let isLockedLine = (sacrificedLineLocks[line] ?? Date()) > Date()

                            let totalLines = station.lines.count
                            let startAngle = Angle(degrees: (360.0 / Double(totalLines)) * Double(index) - 90)
                            let endAngle = Angle(degrees: (360.0 / Double(totalLines)) * Double(index + 1) - 90)


                            // Arc
                            let arcPath = Path { path in
                                path.move(to: center)
                                path.addArc(center: center,
                                            radius: radius,
                                            startAngle: startAngle,
                                            endAngle: endAngle,
                                            clockwise: false)
                            }

                            arcPath.fill(line.color)

                            // Symbol to mask
                            let symbol = Group {
                                if isCompletedBySelf {
                                    Text("✔").font(.caption2).bold().foregroundColor(.white)
                                } else if isCompletedByOtherTeam {
                                    Text("✖").font(.caption2).bold().foregroundColor(.white)
                                } else if isLockedLine {
                                    Text("🔒").font(.caption2)
                                }
                            }

                            // Only show if one of the states applies
                            if isCompletedBySelf || isCompletedByOtherTeam || isLockedLine {
                                symbol
                                    .frame(width: size, height: size)
                                    .position(center)
                                    .mask(
                                        arcPath
                                            .fill(Color.white)
                                    )
                            }
                        }

                        Circle()
                            .stroke(Color.black, lineWidth: 1)
                    }
                }
            }
            .frame(width: 22, height: 22)
        }
    }

    func startLineControlListener() {
        let db = Firestore.firestore()
        let teamsRef = db.collection("games").document(gameID).collection("teams")

        teamsRef.getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }

            for doc in docs {
                let teamID = doc.documentID
                teamsRef.document(teamID)
                    .collection("completedChallenges")
                    .addSnapshotListener { snap, _ in
                        guard let challengeDocs = snap?.documents else { return }

                        var updatedCounts = self.teamLineCounts

                        var lineStationMap: [MetroLine: Set<String>] = [:]

                        for doc in challengeDocs {
                            let station = doc.data()["station"] as? String ?? ""
                            let lineRaw = doc.data()["line"] as? String ?? ""
                            if let line = MetroLine(rawValue: lineRaw) {
                                lineStationMap[line, default: []].insert(station)
                            }
                        }

                        for (line, stations) in lineStationMap {
                            updatedCounts[teamID, default: [:]][line] = stations.count
                        }

                        DispatchQueue.main.async {
                            self.teamLineCounts = updatedCounts
                            self.fetchTeamNames() // Optional, if team names can change
                        }
                    }
            }
        }
    }
    
    private var controlledLineCounts: [String: Int] {
        var result: [String: Int] = [:]

        for teamID in teamLineCounts.keys {
            var controlledLines = 0

            for line in MetroLine.allCases {
                // Get count of stations for each team for this line
                let scores = teamLineCounts.mapValues { $0[line] ?? 0 }

                let maxCount = scores.values.max() ?? 0
                let topTeams = scores.filter { $0.value == maxCount && maxCount > 0 }.keys

                if topTeams.count == 1 && topTeams.contains(teamID) {
                    controlledLines += 1
                }
            }

            result[teamID] = controlledLines
        }

        return result
    }

    func sacrificeChallenge(_ challenge: GameChallenge) {
        sacrificedStations.insert(challenge.station)

        if let line = challenge.line {
            sacrificedLineLocks[line] = Date().addingTimeInterval(20*60) // 20 min
        }

        // ✅ Remove from unlockedChallenges
        unlockedChallenges.removeAll { $0.id == challenge.id }

        if !sacrificedChallenges.contains(where: { $0.id == challenge.id }) {
            sacrificedChallenges.append(challenge)
        }

        let teamRef = Firestore.firestore()
            .collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("unlockedChallenges")

        let safeStation = challenge.station.replacingOccurrences(of: "[^a-zA-Z0-9_]+", with: "_", options: .regularExpression)
        let safeTitle = challenge.title.replacingOccurrences(of: "[^a-zA-Z0-9_]+", with: "_", options: .regularExpression)
        let docID = "\(safeStation)_\(safeTitle)_\(challenge.line?.rawValue ?? "")"

        teamRef.document(docID).delete()

        print("Sacrificed '\(challenge.title)' at \(challenge.station). Line locked for 20 minutes.")
        
        let db = Firestore.firestore()
        let sacrificeRef = db.collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("sacrifices")

        let stationDocID = challenge.station.replacingOccurrences(of: "[^a-zA-Z0-9_]+", with: "_", options: .regularExpression)
        let lineRaw = challenge.line?.rawValue ?? ""

        let sacrificeData: [String: Any] = [
            "station": challenge.station,
            "line": lineRaw,
            "timestamp": Timestamp(),
            "title": challenge.title,
            "description": challenge.description
        ]

        sacrificeRef.document(stationDocID).setData(sacrificeData)
    }
    
    func listenForSacrifices() {
        let db = Firestore.firestore()
        db.collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("sacrifices")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }

                var stations: Set<String> = []
                var locks: [MetroLine: Date] = [:]
                var sacrificed: [GameChallenge] = []

                for doc in docs {
                    let data = doc.data()
                    let station = data["station"] as? String ?? ""
                    let lineRaw = data["line"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let title = data["title"] as? String ?? ""
                    let description = data["description"] as? String ?? ""

                    if let line = MetroLine(rawValue: lineRaw) {
                        stations.insert(station)
                        locks[line] = timestamp.addingTimeInterval(20*60)
                        
                        // ✅ Add to sacrificed challenges array
                        sacrificed.append(GameChallenge(
                            title: title,
                            description: description,
                            station: station,
                            line: line
                        ))
                    }
                }

                DispatchQueue.main.async {
                    self.sacrificedStations = stations
                    self.sacrificedLineLocks = locks
                    self.sacrificedChallenges = sacrificed
                }
            }
    }
}


