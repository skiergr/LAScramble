import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum CreateGameStage {
    case none, username, lobby
}

struct CreateGameView: View {
    @State private var gameStage: CreateGameStage = .none
    @State private var gameID: String = ""
    @State private var username: String = ""
    @State private var errorMessage: String?

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
                Text(error).foregroundColor(.red)
            }
        }
        .padding()
        .fullScreenCover(isPresented: Binding(
            get: { gameStage != .none },
            set: { newVal in if !newVal { gameStage = .none } }
        )) {
            switch gameStage {
            case .username:
                UsernamePromptView(gameID: gameID) { enteredUsername in
                    self.username = enteredUsername
                    self.gameStage = .lobby
                }
            case .lobby:
                LobbyView(gameID: gameID)
            case .none:
                EmptyView()
            }
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

        let gameData: [String: Any] = [
            "createdBy": uid,
            "startTime": Timestamp()
        ]

        gameRef.setData(gameData) { error in
            if let error = error {
                self.errorMessage = "Error creating game: \(error.localizedDescription)"
            } else {
                self.gameID = newGameID
                DispatchQueue.main.async {
                    self.gameStage = .username
                }
            }
        }
    }
}
