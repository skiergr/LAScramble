import SwiftUI
import FirebaseFirestore
import FirebaseAuth

enum JoinGameStage {
    case none, username, lobby
}

struct JoinGameView: View {
    @State private var games: [GameInfo] = []
    @State private var errorMessage: String?

    @State private var stage: JoinGameStage = .none
    @State private var selectedGameID: String = ""
    @State private var username = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Join a Game")
                .font(.title2)
                .padding()

            if let error = errorMessage {
                Text(error).foregroundColor(.red)
            }

            List(games) { game in
                Button(action: {
                    self.selectedGameID = game.id
                    self.stage = .username
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
        .fullScreenCover(isPresented: Binding(
            get: { stage != .none },
            set: { newVal in if !newVal { stage = .none } }
        )) {
            switch stage {
            case .username:
                UsernamePromptView(gameID: selectedGameID) { enteredUsername in
                    self.username = enteredUsername
                    self.stage = .lobby
                }
            case .lobby:
                LobbyView(gameID: selectedGameID)
            case .none:
                EmptyView()
            }
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
}
