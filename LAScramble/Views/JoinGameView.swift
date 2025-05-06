import SwiftUI
import FirebaseFirestore
import FirebaseAuth

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
        }
    }

    func fetchGames() {
        Firestore.firestore().collection("games")
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

                self.games = docs.map {
                    let ts = $0.data()["startTime"] as? Timestamp ?? Timestamp()
                    return GameInfo(id: $0.documentID, createdAt: ts.dateValue())
                }
            }
    }

    func joinGame(gameID: String) {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not logged in"
            return
        }

        let uid = user.uid
        let db = Firestore.firestore()

        db.collection("players").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let username = data["username"] as? String,
                  let teamName = data["teamName"] as? String else {
                errorMessage = "Missing user info"
                return
            }

            let playerData: [String: Any] = [
                "uid": uid,
                "username": username
            ]

            let teamsRef = db.collection("games").document(gameID).collection("teams")
            teamsRef.whereField("teamName", isEqualTo: teamName).getDocuments { querySnapshot, err in
                if let err = err {
                    errorMessage = "Failed to find team: \(err.localizedDescription)"
                    return
                }

                let teamDoc = querySnapshot?.documents.first
                let targetTeamID: String
                let targetTeamRef: DocumentReference

                if let doc = teamDoc {
                    targetTeamID = doc.documentID
                    targetTeamRef = doc.reference
                } else {
                    targetTeamID = "Team-\(uid.prefix(6))"
                    targetTeamRef = teamsRef.document(targetTeamID)
                    targetTeamRef.setData(["teamName": teamName])
                }

                targetTeamRef.collection("players").document(uid).setData(playerData) { err in
                    if let err = err {
                        errorMessage = "Join failed: \(err.localizedDescription)"
                        return
                    }

                    self.joinedTeamIDWrapper = TeamJoinInfo(gameID: gameID, teamID: targetTeamID)
                }
            }
        }
    }
}


struct TeamJoinInfo: Identifiable {
    let gameID: String
    let teamID: String
    var id: String { teamID }
}
