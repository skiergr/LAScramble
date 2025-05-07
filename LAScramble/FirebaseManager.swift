import FirebaseFirestore

class FirebaseManager {
    static let db = Firestore.firestore()

    static func saveUnlockedChallenge(gameID: String, teamID: String, challenge: GameChallenge) {
        let data: [String: Any] = [
            "title": challenge.title,
            "description": challenge.description,
            "station": challenge.station,
            "timestamp": Timestamp()
        ]

        db.collection("games").document(gameID)
            .collection("teams").document(teamID)
            .collection("unlockedChallenges")
            .addDocument(data: data) { error in
                if let error = error {
                    print("Firestore save failed: \(error.localizedDescription)")
                }
            }
    }
}
