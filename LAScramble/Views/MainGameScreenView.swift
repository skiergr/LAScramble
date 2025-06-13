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
    
    @State private var teamColors: [String: Color] = [:]
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var failedChallenges: [GameChallenge] = []
    
    var body: some View {
        Group {
            if gameID.isEmpty || teamID.isEmpty {
                errorView
            } else {
                mainGameContent
            }
        }
        .onAppear(perform: setupListeners)
        .fullScreenCover(item: $selectedStation) { station in
            StationPopupFullScreenView(
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
                failedChallenges: failedChallenges, // ✅ this is the correct label and type
                controllingTeamName: controllingTeamForStation(station),
                teamNames: teamNames,
                myTeamID: teamID,
                selectedLine: selectedLine ?? station.lines.first!,
                allUnlocked: unlockedChallenges,
                allCompleted: completedChallenges,
                globalCompleted: globallyCompleted,
                allOtherUnlocked: otherTeamsUnlocked,
                teamCompletions: allTeamCompletions,
                selectedChallenge: $selectedChallenge,
                selectedStation: $selectedStation
            )
        }
        .fullScreenCover(item: $selectedChallenge) { challenge in
            ChallengePopupView(
                challenge: challenge,
                gameID: gameID,
                teamID: teamID,
                onComplete: {
                    completeChallenge(challenge)
                    selectedChallenge = nil
                },
                onSacrifice: {
                    sacrificeChallenge(challenge)
                    selectedChallenge = nil
                },
                onFail: {
                    failChallenge(challenge)
                    selectedChallenge = nil
                },
                onClose: {
                    selectedChallenge = nil
                },
                selectedStation: $selectedStation,
                selectedChallenge: $selectedChallenge
            )
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
            failedChallenges: failedChallenges,
            controllingTeamName: controllingTeamForStation(station),
            teamNames: teamNames,
            myTeamID: teamID,
            selectedLine: selectedLine ?? station.lines.first!,
            allUnlocked: unlockedChallenges,
            allCompleted: completedChallenges,
            globalCompleted: globallyCompleted,
            allOtherUnlocked: otherTeamsUnlocked,
            teamCompletions: allTeamCompletions,
            selectedChallenge: $selectedChallenge,
            selectedStation: $selectedStation
        )
    }
    
    private func challengePopup(challenge: GameChallenge) -> some View {
        ChallengePopupView(
            challenge: challenge,
            gameID: gameID,
            teamID: teamID,
            onComplete: {
                completeChallenge(challenge)
                selectedChallenge = nil
            },
            onSacrifice: {
                sacrificeChallenge(challenge)
                selectedChallenge = nil
            },
            onFail: {
                failChallenge(challenge)
                selectedChallenge = nil
            },
            onClose: {
                selectedChallenge = nil
            },
            selectedStation: $selectedStation,
            selectedChallenge: $selectedChallenge
        )
    }
    
    private func setupListeners() {
        listenForUnlockedChallenges()
        listenForCompletedChallenges()
        listenForOtherTeams()
        listenForGlobalCompletions()
        updateLineControlScores()
        listenToAllCompletedChallenges()
        listenForFailedChallenges()
        listenForSacrifices()
        fetchTeamName()
        fetchTeamNames()
        fetchStartTimeAndBeginTimer()
        startLineControlListener()
        fetchTeamColors()
    }
    
    
    // MARK: - Main Game UI Extracted to Reduce Complexity
    private var mainGameContent: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(teamColors[teamID] ?? .gray)
                        .frame(width: 10, height: 10)
                    
                    Text(teamName)
                        .font(.headline)
                }
                .padding(.bottom, 2)
                
                Text("\(formatTime(timeRemaining))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
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
                GeometryReader { geometry in
                    ZStack {
                        Image("metro_map")
                            .resizable()
                            .aspectRatio(contentMode: .fit)

                        // Station Dots
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
                                    unlockedChallenges: unlockedChallenges,
                                    allTeamCompletions: allTeamCompletions,
                                    otherTeamsUnlocked: otherTeamsUnlocked,
                                    failedChallenges: failedChallenges, // 👈 Add this
                                    teamID: teamID,
                                    teamColors: teamColors
                                )

                            }
                            .position(
                                x: geometry.size.width * (station.x / 1106),
                                y: geometry.size.height * (station.y / 853)
                            )
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .clipped() // prevent overflow
        }
        .frame(height: UIScreen.main.bounds.height * 0.35)
        .background(Color.white) // ensures visibility in dark mode
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
                
                ZStack {
                    content
                        .scaleEffect(scale)
                        .offset(offset)
                }
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
                                let proposed = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                                offset = clampedOffset(proposed, in: containerSize)
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                )
                .animation(.easeInOut(duration: 0.2), value: scale)
            }
        }
        
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
                
                // Filter active challenges separately
                let activeChallenges = unlockedChallenges.filter { challenge in
                    let isCompleted = globallyCompleted.contains { $0.title == challenge.title && $0.station == challenge.station }
                    let isSacrificed = sacrificedStations.contains(challenge.station)
                    let isFailed = failedChallenges.contains { $0.station == challenge.station && $0.line == challenge.line }
                    return !isCompleted && !isSacrificed && !isFailed
                }

                // Filter other teams' unlocked challenges separately
                let othersRaw = otherTeamsUnlocked
                    .flatMap { (teamID, list) in list.map { (teamID, $0) } }

                let others = othersRaw.filter { (_, ch) in
                    let isMine = unlockedChallenges.contains { $0.title == ch.title && $0.station == ch.station && $0.line == ch.line }
                    let isCompleted = globallyCompleted.contains { $0.title == ch.title && $0.station == ch.station && $0.line == ch.line }
                    let isFailed = failedChallenges.contains { $0.title == ch.title && $0.station == ch.station && $0.line == ch.line }
                    let isSacrificed = sacrificedStations.contains(ch.station)
                    return !isMine && !isCompleted && !isFailed && !isSacrificed
                }

                let completedByOthers = globallyCompleted.filter {
                    !completedChallenges.contains($0)
                }

                // Active Challenges
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

                // Failed Challenges
                if !failedChallenges.isEmpty {
                    Text("Failed Challenges").font(.headline)
                    ForEach(failedChallenges) { challenge in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(challenge.title).italic().foregroundColor(.gray)
                            Text("\(challenge.station)")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.05))
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
        
        if failedChallenges.contains(where: { $0.station == station.name && $0.line == line }) {
            alertMessage = "You already failed the challenge at this station on this line."
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
                let challenge = GameChallenge(
                    title: title,
                    description: description,
                    station: stationName,
                    line: globalLine,
                    canFail: data["canFail"] as? Bool ?? true
                )

                
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
                    line: line,
                    canFail: random.canFail
                )
                
                let data: [String: Any] = [
                    "title": chosenChallenge.title,
                    "description": chosenChallenge.description,
                    "station": chosenChallenge.station,
                    "line": chosenChallenge.line?.rawValue ?? "",
                    "timestamp": Timestamp(),
                    "sacrificed": false,
                    "canFail": chosenChallenge.canFail ?? true
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
            "sacrificed": sacrificed,
            "canFail": challenge.canFail ?? true  // ✅ FIXED
        ]
        
        let teamRef = Firestore.firestore()
            .collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("unlockedChallenges")
        
        let rawID = "\(challenge.station)_\(challenge.title)_\(challenge.line?.rawValue ?? "")"
        let docID = rawID
            .replacingOccurrences(of: "[^a-zA-Z0-9_]+", with: "_", options: .regularExpression)
            .replacingOccurrences(of: "_+", with: "_")
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
    
    func failChallenge(_ challenge: GameChallenge) {
        // Remove from local list
        unlockedChallenges.removeAll { $0.id == challenge.id }

        // Save to failedChallenges
        let data: [String: Any] = [
            "title": challenge.title,
            "station": challenge.station,
            "line": challenge.line?.rawValue ?? "",
            "timestamp": Timestamp()
        ]

        Firestore.firestore().collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("failedChallenges").addDocument(data: data)

        // ✅ Delete from unlockedChallenges in Firestore (so other teams won’t see it)
        let safeStation = challenge.station.replacingOccurrences(of: "[^a-zA-Z0-9_]+", with: "_", options: .regularExpression)
        let safeTitle = challenge.title.replacingOccurrences(of: "[^a-zA-Z0-9_]+", with: "_", options: .regularExpression)
        let safeLine = challenge.line?.rawValue ?? ""
        let docID = "\(safeStation)_\(safeTitle)_\(safeLine)"
            .replacingOccurrences(of: "_+", with: "_")
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))

        Firestore.firestore().collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("unlockedChallenges")
            .document(docID)
            .delete()

        print("❌ Marked challenge as failed and deleted from unlocked: \(challenge.title)")
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
                        line: MetroLine(rawValue: d["line"] as? String ?? ""),
                        canFail: d["canFail"] as? Bool
                    )
                }
            }
    }
    
    func listenForFailedChallenges() {
        let db = Firestore.firestore()
        db.collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("failedChallenges")
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                let failed = docs.map { doc in
                    GameChallenge(
                        title: doc["title"] as? String ?? "",
                        description: "",
                        station: doc["station"] as? String ?? "",
                        line: MetroLine(rawValue: doc["line"] as? String ?? ""),
                        canFail: nil
                    )
                }

                self.failedChallenges = failed
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
                                title: d["title"] as? String ?? "",
                                description: d["description"] as? String ?? "",
                                station: d["station"] as? String ?? "",
                                line: MetroLine(rawValue: d["line"] as? String ?? ""),
                                canFail: d["canFail"] as? Bool
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
                        line: MetroLine(rawValue: d["line"] as? String ?? ""),
                        canFail: d["canFail"] as? Bool
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
                        line: MetroLine(rawValue: d["line"] as? String ?? ""),
                        canFail: d["canFail"] as? Bool
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
                        line: MetroLine(rawValue: d["line"] as? String ?? ""),
                        canFail: d["canFail"] as? Bool
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
        let unlockedChallenges: [GameChallenge]
        let allTeamCompletions: [String: [GameChallenge]]
        let otherTeamsUnlocked: [String: [GameChallenge]]
        let failedChallenges: [GameChallenge]
        let teamID: String
        let teamColors: [String: Color]
        
        var body: some View {
            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height)
                let center = CGPoint(x: size / 2, y: size / 2)
                let outerRadius = size / 2
                let innerRadius = outerRadius * 0.75
                let symbolRadius = innerRadius * 0.65
                let stationName = station.name
                
                ZStack {
                    // Outer ring segments (line colors)
                    ForEach(Array(station.lines.enumerated()), id: \.offset) { index, line in
                        let angleSize = 360.0 / Double(station.lines.count)
                        let startAngle = Angle(degrees: angleSize * Double(index) - 90)
                        let endAngle = Angle(degrees: angleSize * Double(index + 1) - 90)
                        
                        Path { path in
                            path.move(to: center)
                            path.addArc(center: center, radius: outerRadius,
                                        startAngle: startAngle, endAngle: endAngle,
                                        clockwise: false)
                            path.closeSubpath()
                        }
                        .fill(line.color)
                    }
                    
                    // Inner circle segments (status fill colors)
                    ForEach(Array(station.lines.enumerated()), id: \.offset) { index, line in
                        let angleSize = 360.0 / Double(station.lines.count)
                        let startAngle = Angle(degrees: angleSize * Double(index) - 90)
                        let endAngle = Angle(degrees: angleSize * Double(index + 1) - 90)
                        
                        let sacrificed = sacrificedStations.contains(stationName)
                        let failed = failedChallenges.contains { $0.station == stationName && $0.line == line }
                        let myCompleted = completedChallenges.contains { $0.station == stationName && $0.line == line }
                        let myUnlocked = unlockedChallenges.contains { $0.station == stationName && $0.line == line }
                        let globally = globallyCompleted.first { $0.station == stationName && $0.line == line }
                        let completedBy = globally.flatMap { challenge in
                            allTeamCompletions.first { $0.value.contains(challenge) }?.key
                        }
                        let otherTeam = otherTeamsUnlocked.first(where: { (teamID, challenges) in
                            challenges.contains(where: { challenge in
                                challenge.station == stationName &&
                                challenge.line == line &&
                                !failedChallenges.contains(where: {
                                    $0.station == challenge.station && $0.line == challenge.line
                                })
                            })
                        })?.key

                        
                        let fillColor: Color = {
                            if sacrificed {
                                return .gray
                            } else if failed {
                                return .black
                            } else if myCompleted {
                                return teamColors[teamID] ?? .blue
                            } else if let team = completedBy {
                                return teamColors[team] ?? .black
                            } else if myUnlocked {
                                return teamColors[teamID] ?? .blue
                            } else if let team = otherTeam {
                                return teamColors[team] ?? .green
                            } else {
                                return .white
                            }
                        }()
                        
                        Path { path in
                            path.move(to: center)
                            path.addArc(center: center, radius: innerRadius,
                                        startAngle: startAngle, endAngle: endAngle,
                                        clockwise: false)
                            path.closeSubpath()
                        }
                        .fill(fillColor)
                    }
                    
                    // Symbols: ✔ or ✖ (centered or segmented)
                    if station.lines.count == 1 {
                        let line = station.lines[0]
                        let myCompleted = completedChallenges.contains { $0.station == stationName && $0.line == line }
                        let globally = globallyCompleted.first { $0.station == stationName && $0.line == line }
                        let completedBy = globally.flatMap { challenge in
                            allTeamCompletions.first { $0.value.contains(challenge) }?.key
                        }
                        let sacrificed = sacrificedStations.contains(stationName)
                        let failed = failedChallenges.contains { $0.station == stationName && $0.line == line }

                        let symbol: String? = {
                            if sacrificed || failed {
                                return "✖"
                            } else if myCompleted {
                                return "✔"
                            } else if let team = completedBy {
                                return team == teamID ? "✔" : "✖"
                            } else {
                                return nil
                            }
                        }()
                        
                        if let symbol = symbol {
                            Text(symbol)
                                .font(.caption2).bold()
                                .foregroundColor(.white)
                                .position(center)
                        }
                    } else {
                        ForEach(Array(station.lines.enumerated()), id: \.offset) { index, line in
                            let angleSize = 360.0 / Double(station.lines.count)
                            let midAngle = Angle(degrees: angleSize * (Double(index) + 0.5) - 90)
                            let symbolX = center.x + symbolRadius * CGFloat(cos(midAngle.radians))
                            let symbolY = center.y + symbolRadius * CGFloat(sin(midAngle.radians))
                            let symbolPos = CGPoint(x: symbolX, y: symbolY)
                            
                            let myCompleted = completedChallenges.contains { $0.station == stationName && $0.line == line }
                            let globally = globallyCompleted.first { $0.station == stationName && $0.line == line }
                            let completedBy = globally.flatMap { challenge in
                                allTeamCompletions.first { $0.value.contains(challenge) }?.key
                            }
                            let sacrificed = sacrificedStations.contains(stationName)
                            let failed = failedChallenges.contains { $0.station == stationName && $0.line == line }
                            
                            let symbol: String? = {
                                if sacrificed || failed {
                                    return "✖"
                                } else if myCompleted {
                                    return "✔"
                                } else if let team = completedBy {
                                    return team == teamID ? "✔" : "✖"
                                } else {
                                    return nil
                                }
                            }()
                            
                            if let symbol = symbol {
                                Text(symbol)
                                    .font(.caption2).bold()
                                    .foregroundColor(.white)
                                    .position(symbolPos)
                            }
                        }
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
                            line: line,
                            canFail: nil
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
    func fetchTeamColors() {
        let db = Firestore.firestore()
        db.collection("games").document(gameID).collection("teams").getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            
            var colorMap: [String: Color] = [:]
            for doc in docs {
                let teamID = doc.documentID
                if let colorNameRaw = doc.data()["teamColor"] as? String {
                    let colorName = colorNameRaw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    colorMap[teamID] = mapColorNameToSwiftUIColor(colorName)
                }
            }
            
            DispatchQueue.main.async {
                self.teamColors = colorMap
            }
        }
    }
    
    func mapColorNameToSwiftUIColor(_ name: String) -> Color {
        switch name {
            case "blue": return .blue
            case "green": return .green
            case "red": return .red
            case "purple": return .purple
            case "orange": return .orange
            case "pink": return .pink
            case "yellow": return .yellow
            default: return .gray
        }
    }
}


//#Preview {
//    MainGameScreenView(gameID: "preview", teamID: "previewTeam")
//}
