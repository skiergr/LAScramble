import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CreateGameView: View {
    @State private var gameCreated = false
    @State private var errorMessage: String?
    @State private var gameID: String = ""
    @State private var teamID: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Start a New Game")
                .font(.title2)
                .padding()

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
        .fullScreenCover(isPresented: Binding<Bool>(
            get: { gameCreated && !gameID.isEmpty && !teamID.isEmpty },
            set: { _ in }
        )) {
            MainGameScreenView(gameID: gameID, teamID: teamID)
        }
    }

    func createGame() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not logged in"
            return
        }

        let db = Firestore.firestore()
        let gameRef = db.collection("games").document()
        let newGameID = gameRef.documentID
        let newTeamID = "Team-\(user.uid.prefix(6))"
        self.teamID = newTeamID

        let playerData: [String: Any] = [
            "uid": user.uid,
            "username": user.email ?? "Unknown"
        ]

        // Write to game document
        let gameData: [String: Any] = [
            "startTime": Timestamp(),
            "createdBy": user.uid,
            "teams": [newTeamID],
            "players": [playerData]
        ]

        // Write to team subcollection
        let teamData: [String: Any] = [
            "players": [playerData]
        ]

        gameRef.setData(gameData) { error in
            if let error = error {
                errorMessage = "Error creating game: \(error.localizedDescription)"
                return
            }

            gameRef.collection("teams").document(newTeamID).setData(teamData) { err in
                if let err = err {
                    errorMessage = "Error adding creator team: \(err.localizedDescription)"
                    return
                }

                print("✅ Game created with ID: \(newGameID), Team ID: \(newTeamID)")
                gameID = newGameID
                gameCreated = true
            }
        }
    }
}
