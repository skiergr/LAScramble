import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateGameView: View {
    @State private var gameCreated = false
    @State private var errorMessage: String?
    @State private var gameID: String = ""
    @State private var teamID: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Start a New Game")
                .font(.title2)

            Button("Create Game") {
                createGame()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            if let error = errorMessage {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .fullScreenCover(isPresented: Binding(get: {
            gameCreated && !gameID.isEmpty && !teamID.isEmpty
        }, set: { _ in })) {
            LobbyView(gameID: gameID, teamID: teamID)
        }
    }

    func createGame() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not logged in"
            return
        }

        let uid = user.uid
        let db = Firestore.firestore()
        let gameRef = db.collection("games").document()
        let newGameID = gameRef.documentID
        let newTeamID = "Team-\(uid.prefix(6))"
        self.teamID = newTeamID

        // Fetch username and teamName from /players/{uid}
        db.collection("players").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let username = data["username"] as? String,
                  let teamName = data["teamName"] as? String else {
                errorMessage = "Missing player info"
                return
            }

            // Create game doc
            let gameData: [String: Any] = [
                "createdBy": uid,
                "startTime": Timestamp()
            ]

            let playerData: [String: Any] = [
                "uid": uid,
                "username": username
            ]

            let teamData: [String: Any] = [
                "teamName": teamName
            ]

            gameRef.setData(gameData) { error in
                if let error = error {
                    errorMessage = "Error creating game: \(error.localizedDescription)"
                    return
                }

                let teamRef = gameRef.collection("teams").document(newTeamID)
                teamRef.setData(teamData) { error in
                    if let error = error {
                        errorMessage = "Error creating team: \(error.localizedDescription)"
                        return
                    }

                    teamRef.collection("players").document(uid).setData(playerData) { error in
                        if let error = error {
                            errorMessage = "Error adding player: \(error.localizedDescription)"
                            return
                        }

                        self.gameID = newGameID
                        self.gameCreated = true
                    }
                }
            }
        }
    }
}
