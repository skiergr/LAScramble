import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct JoinGameView: View {
    @State private var games: [GameInfo] = []
    @State private var errorMessage: String?

    @State private var joinedTeamIDWrapper: TeamJoinInfo?

    var body: some View {
        VStack(spacing: 16) {
            Text("Join a Game")
                .font(.title2)
                .padding()

            if let error = errorMessage {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
            }

            List(games) { game in
                Button(action: {
                    joinGame(gameID: game.id)
                }) {
                    VStack(alignment: .leading) {
                        Text("Game ID: \(game.id.prefix(6))")
                        Text("Created: \(game.createdAt.formatted())")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .onAppear(perform: fetchGames)
        .fullScreenCover(item: $joinedTeamIDWrapper) { wrapper in
            MainGameScreenView(gameID: wrapper.gameID, teamID: wrapper.teamID)
                .onAppear {
                    print("🚀 Navigated to MainGameScreenView with gameID: \(wrapper.gameID), teamID: \(wrapper.teamID)")
                }
        }
    }

    func fetchGames() {
        let db = Firestore.firestore()
        db.collection("games")
            .order(by: "startTime", descending: true)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                if let error = error {
                    errorMessage = "Failed to load games: \(error.localizedDescription)"
                    return
                }

                guard let docs = snapshot?.documents else {
                    errorMessage = "No games found"
                    return
                }

                self.games = docs.map { doc in
                    let data = doc.data()
                    let timestamp = data["startTime"] as? Timestamp ?? Timestamp()
                    return GameInfo(id: doc.documentID, createdAt: timestamp.dateValue())
                }

                print("📦 Fetched \(self.games.count) games")
            }
    }

    func joinGame(gameID: String) {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not logged in"
            return
        }

        let newTeamID = "Team-\(user.uid.prefix(6))"
        let db = Firestore.firestore()

        print("🔍 Attempting to join game \(gameID) as \(newTeamID)")

        let playerData: [String: Any] = [
            "uid": user.uid,
            "username": user.email ?? "Unknown"
        ]

        let teamRef = db.collection("games").document(gameID)
            .collection("teams").document(newTeamID)

        teamRef.setData(["players": [playerData]]) { error in
            if let error = error {
                errorMessage = "Failed to join game: \(error.localizedDescription)"
                return
            }

            print("✅ Joined game \(gameID) as \(newTeamID)")

            DispatchQueue.main.async {
                self.joinedTeamIDWrapper = TeamJoinInfo(gameID: gameID, teamID: newTeamID)
            }
        }
    }
}

// MARK: - Helpers


struct TeamJoinInfo: Identifiable {
    let gameID: String
    let teamID: String
    var id: String { teamID }
}
