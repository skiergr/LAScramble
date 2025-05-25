import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct LobbyView: View {
    var gameID: String
    var teamID: String

    @State private var teams: [String: [String]] = [:]           // [teamID: [usernames]]
    @State private var teamNames: [String: String] = [:]         // [teamID: teamName]
    @State private var selectedColors: [String: String] = [:]    // [teamID: color name string]
    @State private var teamColors: [String: Color] = [:]         // [teamID: actual Color]

    @State private var isCreator = false
    @State private var hasStarted = false
    
    @State private var showColorAlert = false
    @State private var alertMessage = ""

    let availableColors = ["blue", "green", "red", "purple", "orange", "pink", "yellow"]

    var body: some View {
        VStack {
            Text("Lobby").font(.largeTitle).padding(.top)

            Text("Game ID: \(gameID)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 8)

            ScrollView {
                ForEach(teams.keys.sorted(), id: \.self) { id in
                    VStack(alignment: .leading) {
                        HStack {
                            Circle()
                                .fill(teamColors[id] ?? .gray)
                                .frame(width: 12, height: 12)

                            Text(teamNames[id] ?? "Team")
                                .font(.headline)

                            if id == teamID {
                                Picker("Color", selection: Binding(
                                    get: { selectedColors[teamID] ?? "blue" },
                                    set: { newColor in
                                        let isTaken = selectedColors.contains(where: { $0.key != teamID && $0.value == newColor })
                                        if isTaken {
                                            alertMessage = "That color is already taken by another team."
                                            showColorAlert = true
                                        } else {
                                            selectedColors[teamID] = newColor
                                            saveTeamColor(teamID: teamID, color: newColor)
                                        }
                                    })) {
                                        ForEach(availableColors, id: \.self) { color in
                                            let isTaken = selectedColors.contains(where: { $0.key != teamID && $0.value == color })
                                            Text(color.capitalized)
                                                .tag(color)
                                                .foregroundColor(isTaken ? .gray : .primary)
                                                .opacity(isTaken ? 0.4 : 1.0)
                                        }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        }

                        ForEach(teams[id] ?? [], id: \.self) { username in
                            Text(username)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }

            if isCreator {
                Button("Start Game") {
                    startGame()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom)
            }
        }
        .onAppear {
            fetchTeamsAndPlayersLive()
            fetchTeamColors()
            checkIfCreator()
            listenForStart()
        }
        .fullScreenCover(isPresented: $hasStarted) {
            MainGameScreenView(gameID: gameID, teamID: teamID)
        }
        .alert(isPresented: $showColorAlert) {
            Alert(title: Text("Color Unavailable"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Firestore Listeners

    func fetchTeamsAndPlayersLive() {
        let db = Firestore.firestore()
        let teamsRef = db.collection("games").document(gameID).collection("teams")

        teamsRef.addSnapshotListener { snapshot, _ in
            guard let docs = snapshot?.documents else { return }

            var takenColors = Set<String>()

            for doc in docs {
                //let id = doc.documentID
                var colorName = doc.data()["teamColor"] as? String

                if let existingColor = colorName {
                    takenColors.insert(existingColor.lowercased())
                }
            }

            for doc in docs {
                let id = doc.documentID
                let teamName = doc.data()["teamName"] as? String ?? "Unnamed Team"
                var colorName = doc.data()["teamColor"] as? String

                // If no color assigned, assign first unused one
                if colorName == nil || !availableColors.contains(colorName!.lowercased()) {
                    if let available = availableColors.first(where: { !takenColors.contains($0) }) {
                        colorName = available
                        takenColors.insert(available)
                        saveTeamColor(teamID: id, color: available)
                    } else {
                        colorName = "gray" // fallback if no color available
                    }
                }

                DispatchQueue.main.async {
                    self.teamNames[id] = teamName
                    self.selectedColors[id] = colorName
                    self.teamColors[id] = mapColorNameToSwiftUIColor(colorName ?? "gray")
                }

                db.collection("games").document(gameID)
                    .collection("teams").document(id)
                    .collection("players")
                    .addSnapshotListener { snap, _ in
                        let usernames = snap?.documents.map {
                            $0.data()["username"] as? String ?? "Unknown"
                        } ?? []

                        DispatchQueue.main.async {
                            self.teams[id] = usernames
                        }
                    }
            }
        }
    }


    func fetchTeamColors() {
        let db = Firestore.firestore()
        db.collection("games").document(gameID).collection("teams").getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }

            var colorMap: [String: Color] = [:]
            var nameMap: [String: String] = [:]
            for doc in docs {
                let id = doc.documentID
                let rawColor = (doc.data()["teamColor"] as? String ?? "gray").lowercased()
                colorMap[id] = mapColorNameToSwiftUIColor(rawColor)
                nameMap[id] = rawColor
            }

            DispatchQueue.main.async {
                self.teamColors = colorMap
                self.selectedColors = nameMap
            }
        }
    }

    func checkIfCreator() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("games").document(gameID).getDocument { snapshot, _ in
            let creatorID = snapshot?.data()?["createdBy"] as? String ?? ""
            self.isCreator = (creatorID == uid)
        }
    }

    func listenForStart() {
        Firestore.firestore().collection("games").document(gameID)
            .addSnapshotListener { snapshot, _ in
                let started = snapshot?.data()?["hasStarted"] as? Bool ?? false
                if started {
                    self.hasStarted = true
                }
            }
    }

    // MARK: - Actions

    func startGame() {
        Firestore.firestore().collection("games").document(gameID).updateData([
            "hasStarted": true,
            "startTime": Timestamp()
        ])
    }

    func saveTeamColor(teamID: String, color: String) {
        let db = Firestore.firestore()
        let teamsRef = db.collection("games").document(gameID).collection("teams")

        // Check if color is taken
        teamsRef.getDocuments { snapshot, error in
            guard let docs = snapshot?.documents, error == nil else { return }

            let taken = docs.contains { doc in
                let docTeamID = doc.documentID
                let currentColor = doc.data()["teamColor"] as? String ?? ""
                return docTeamID != teamID && currentColor.lowercased() == color.lowercased()
            }

            if taken {
                print("⚠️ Color '\(color)' already taken.")
                return
            }

            teamsRef.document(teamID).updateData(["teamColor": color.lowercased()])
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
