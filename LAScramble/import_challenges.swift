//
//  ChallengeImporter.swift
//  Stand-alone CLI or macOS Command-Line target
//

import Foundation
import FirebaseCore
import FirebaseFirestore

// ──────────────────────────────────────────────────────────
// MARK: - Data model + full sampleChallenges array
// (Your entire sample list lives here unchanged.)
// ──────────────────────────────────────────────────────────


// 🔻 Paste **all** your sampleChallenges items here (kept short for brevity)
let correctSampleChallenges: [GameChallenge] = [
]


/// Call once to ensure Firebase is ready.
private func configureFirebase() {
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }
}

/// Converts GameChallenge → [String: Any] dictionary
private func dict(from ch: GameChallenge) -> [String: Any] {
    [
        "title"      : ch.title,
        "description": ch.description,
        "station"    : ch.station,
        "line"       : ch.line?.rawValue as Any,   // nil becomes NSNull → omitted
        "canFail"    : ch.canFail ?? false
    ]
}

/// Uploads the entire sampleChallenges list to Firestore.
private func uploadChallenges() async {
    configureFirebase()
    let db = Firestore.firestore()
    let collection = db.collection("challenges")

    print("🔄 Uploading \(correctSampleChallenges.count) challenges …")

    for challenge in correctSampleChallenges {
        do {
            try await collection.addDocument(data: dict(from: challenge))
            print("   ✅ \(challenge.title)")
        } catch {
            print("   ❌ \(challenge.title) — \(error.localizedDescription)")
        }
    }

    print("🎉 Finished: \(correctSampleChallenges.count) uploaded.")
}

// ──────────────────────────────────────────────────────────
// MARK: - Async executable entry point
// ──────────────────────────────────────────────────────────
/*
@main
struct ChallengeImporter {
    static func main() async {
        print("Top-level init complete")
        print("correctSampleChallenges.count =", correctSampleChallenges.count)

        await uploadChallenges()
        // Exit cleanly
        exit(EXIT_SUCCESS)
    }
}*/

