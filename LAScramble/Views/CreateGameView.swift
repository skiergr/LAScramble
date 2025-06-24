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

    // ✅ New fields
    @State private var gameDurationInput: String = "120"
    @State private var sacrificeDurationInput: String = "20"

    var body: some View {
        VStack(spacing: 20) {
            Text("Start a New Game")
                .font(.title2)

            VStack(alignment: .leading, spacing: 8) {
                Text("Game Duration (minutes)")
                TextField("e.g. 120", text: $gameDurationInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Text("Sacrifice Lockout Time (minutes)")
                TextField("e.g. 20", text: $sacrificeDurationInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

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

        guard let gameDuration = Int(gameDurationInput),
              let sacrificeDuration = Int(sacrificeDurationInput) else {
            errorMessage = "Please enter valid numbers for duration."
            return
        }

        let uid = user.uid
        let db = Firestore.firestore()

        func generateGameID() -> String {
            let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
            return String((0..<5).map { _ in chars.randomElement()! })
        }

        func tryCreateGame() {
            let newGameID = generateGameID()
            let gameRef = db.collection("games").document(newGameID)

            gameRef.getDocument { snapshot, error in
                if let error = error {
                    self.errorMessage = "Error checking game ID: \(error.localizedDescription)"
                    return
                }

                if snapshot?.exists == true {
                    // ID already taken, try again
                    tryCreateGame()
                } else {
                    // Unique ID, create game
                    let gameData: [String: Any] = [
                        "createdBy": uid,
                        "startTime": Timestamp(),
                        "gameDurationMinutes": gameDuration,
                        "sacrificeDurationMinutes": sacrificeDuration
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
        }

        tryCreateGame()
    }
}
