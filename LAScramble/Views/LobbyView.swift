import SwiftUI
import FirebaseFirestore
import FirebaseAuth

enum LobbyStage {
    case none, createTeam, inGame
}

struct LobbyView: View {
    let gameID: String

    @Environment(\.presentationMode) var presentationMode
    @State private var teams: [String: [String]] = [:]
    @State private var teamNames: [String: String] = [:]
    @State private var selectedColors: [String: String] = [:]
    @State private var teamColors: [String: Color] = [:]

    @State private var myTeamID: String?
    @State private var username: String = ""
    @State private var newTeamName = ""
    @State private var chosenColor = "blue"

    @State private var isCreator = false
    @State private var stage: LobbyStage = .none
    @State private var alertMessage = ""
    @State private var showColorAlert = false
    @State private var showLeaveConfirm = false

    @State private var allPlayersAssigned = false

    let availableColors = ["blue", "green", "red", "purple", "orange", "pink", "yellow"]

    var body: some View {
        NavigationView {
            VStack {
                Text("Lobby").font(.largeTitle).padding(.top)
                Text("Game ID: \(gameID)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom)

                ScrollView {
                    ForEach(teams.keys.sorted(), id: \.self) { teamID in
                        VStack(alignment: .leading) {
                            HStack {
                                Circle()
                                    .fill(teamColors[teamID] ?? .gray)
                                    .frame(width: 12, height: 12)

                                Text(teamNames[teamID] ?? "Unnamed Team")
                                    .font(.headline)

                                Spacer()

                                if myTeamID == nil {
                                    Button("Join") {
                                        joinTeam(teamID: teamID)
                                    }
                                    .buttonStyle(.bordered)
                                } else if myTeamID == teamID {
                                    Text("Joined").font(.caption).foregroundColor(.green)
                                }
                            }

                            ForEach(teams[teamID] ?? [], id: \.self) { player in
                                Text(player).font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }

                if myTeamID == nil {
                    Button("Create New Team") {
                        stage = .createTeam
                    }
                    .padding()
                }

                if isCreator {
                    Button("Start Game") {
                        startGame()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button(action: {
                    showLeaveConfirm = true
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            )
            .alert(isPresented: $showColorAlert) {
                Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .confirmationDialog("Leave Game?", isPresented: $showLeaveConfirm, titleVisibility: .visible) {
                Button("Leave and Clear Game", role: .destructive) {
                    UserDefaults.standard.removeObject(forKey: "cachedGameID")
                    UserDefaults.standard.removeObject(forKey: "cachedTeamID")
                    presentationMode.wrappedValue.dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
            .fullScreenCover(isPresented: Binding(
                get: { stage != .none },
                set: { newVal in if !newVal { stage = .none } }
            )) {
                switch stage {
                case .createTeam:
                    createTeamSheet
                case .inGame:
                    if let teamID = myTeamID {
                        MainGameScreenView(gameID: gameID, teamID: teamID)
                    }
                case .none:
                    EmptyView()
                }
            }
            .onAppear {
                fetchLiveLobbyData()
                fetchUsername()
                checkIfCreator()
                listenForStart()
            }
        }
    }

    private var createTeamSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create New Team").font(.headline)

                TextField("Team Name", text: $newTeamName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Picker("Color", selection: $chosenColor) {
                    ForEach(availableColors, id: \.self) { color in
                        let taken = selectedColors.contains { $0.value == color }
                        Text(color.capitalized)
                            .foregroundColor(taken ? .gray : .primary)
                            .opacity(taken ? 0.5 : 1)
                            .tag(color)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                Button("Create") {
                    createTeam()
                }
                .disabled(newTeamName.isEmpty)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()
            }
            .padding()
            .navigationTitle("New Team")
        }
    }

    func fetchUsername() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("games").document(gameID)
            .collection("players").document(uid)
            .getDocument { snapshot, _ in
                if let data = snapshot?.data(),
                   let name = data["username"] as? String {
                    self.username = name
                }
            }
    }

    func fetchLiveLobbyData() {
        let db = Firestore.firestore()
        let teamsRef = db.collection("games").document(gameID).collection("teams")

        teamsRef.addSnapshotListener { snapshot, _ in
            guard let docs = snapshot?.documents else { return }

            var newTeams: [String: [String]] = [:]
            var newTeamNames: [String: String] = [:]
            var newSelectedColors: [String: String] = [:]
            var newTeamColors: [String: Color] = [:]

            for doc in docs {
                let id = doc.documentID
                let data = doc.data()
                let name = data["teamName"] as? String ?? "Unnamed"
                let color = data["teamColor"] as? String ?? "gray"

                newTeamNames[id] = name
                newSelectedColors[id] = color
                newTeamColors[id] = mapColorNameToSwiftUIColor(color)

                teamsRef.document(id).collection("players").addSnapshotListener { snap, _ in
                    let users = snap?.documents.map {
                        $0.data()["username"] as? String ?? "Unknown"
                    } ?? []

                    DispatchQueue.main.async {
                        newTeams[id] = users
                        self.teams = newTeams
                    }
                }
            }

            DispatchQueue.main.async {
                self.teamNames = newTeamNames
                self.selectedColors = newSelectedColors
                self.teamColors = newTeamColors
            }
        }
    }

    func checkIfCreator() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("games").document(gameID).getDocument { snapshot, _ in
            let creator = snapshot?.data()?["createdBy"] as? String ?? ""
            self.isCreator = (creator == uid)
        }
    }

    func listenForStart() {
        Firestore.firestore().collection("games").document(gameID)
            .addSnapshotListener { snapshot, _ in
                let started = snapshot?.data()?["hasStarted"] as? Bool ?? false
                if started {
                    self.stage = .inGame
                }
            }
    }

    func createTeam() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let teamsRef = Firestore.firestore()
            .collection("games").document(gameID)
            .collection("teams")

        teamsRef.whereField("teamColor", isEqualTo: chosenColor).getDocuments { snapshot, error in
            if let error = error {
                self.alertMessage = "Error checking colors: \(error.localizedDescription)"
                self.showColorAlert = true
                return
            }

            if let docs = snapshot?.documents, !docs.isEmpty {
                self.alertMessage = "That color is already taken. Please choose another."
                self.showColorAlert = true
                return
            }

            let teamID = "team-\(UUID().uuidString.prefix(6))"
            let teamRef = teamsRef.document(teamID)

            let teamData: [String: Any] = [
                "teamName": newTeamName,
                "teamColor": chosenColor
            ]

            let playerData: [String: Any] = [
                "uid": uid,
                "username": username
            ]

            teamRef.setData(teamData)
            teamRef.collection("players").document(uid).setData(playerData)

            DispatchQueue.main.async {
                myTeamID = teamID
                stage = .none
            }
            UserDefaults.standard.set(teamID, forKey: "cachedTeamID")
        }
    }

    func joinTeam(teamID: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let playerData: [String: Any] = [
            "uid": uid,
            "username": username
        ]

        Firestore.firestore()
            .collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("players").document(uid)
            .setData(playerData)

        myTeamID = teamID
        UserDefaults.standard.set(teamID, forKey: "cachedTeamID")
    }

    func startGame() {
        let db = Firestore.firestore()
        let gameRef = db.collection("games").document(gameID)
        let teamsRef = gameRef.collection("teams")
        let playersRef = gameRef.collection("players")

        playersRef.getDocuments { playerSnapshot, error in
            guard let playerDocs = playerSnapshot?.documents else {
                self.alertMessage = "Failed to fetch players"
                self.showColorAlert = true
                return
            }

            let allPlayerIDs = Set(playerDocs.map { $0.documentID })

            teamsRef.getDocuments { teamSnapshot, _ in
                guard let teamDocs = teamSnapshot?.documents else { return }

                var teamPlayerIDs = Set<String>()
                let dispatchGroup = DispatchGroup()

                for teamDoc in teamDocs {
                    dispatchGroup.enter()
                    teamsRef.document(teamDoc.documentID).collection("players").getDocuments { snap, _ in
                        if let docs = snap?.documents {
                            for doc in docs {
                                teamPlayerIDs.insert(doc.documentID)
                            }
                        }
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    let unassignedPlayers = allPlayerIDs.subtracting(teamPlayerIDs)

                    if !unassignedPlayers.isEmpty {
                        self.alertMessage = "All players must be on a team to start the game."
                        self.showColorAlert = true
                    } else {
                        gameRef.updateData([
                            "hasStarted": true,
                            "startTime": Timestamp()
                        ])
                    }
                }
            }
        }
    }

    func mapColorNameToSwiftUIColor(_ name: String) -> Color {
        switch name.lowercased() {
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
