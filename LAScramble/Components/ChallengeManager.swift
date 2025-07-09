//
//  ChallengeManager.swift
//  LAScramble
//
//  Created by Grady Ramberg on 6/26/25.
//
import SwiftUI
import FirebaseFirestore

func fetchAllChallenges(completion: @escaping ([GameChallenge]) -> Void) {
    let db = Firestore.firestore()
    db.collection("challenges").getDocuments { snapshot, error in
        guard let docs = snapshot?.documents, error == nil else {
            print("❌ Fetch error: \(error?.localizedDescription ?? "Unknown")")
            completion([])
            return
        }

        let challenges = docs.compactMap { doc -> GameChallenge? in
            let data = doc.data()
            guard let title = data["title"] as? String,
                  let description = data["description"] as? String,
                  let station = data["station"] as? String else { return nil }

            let canFail = data["canFail"] as? Bool ?? false
            let lineString = data["line"] as? String
            let line = lineString.flatMap { MetroLine(rawValue: $0) }

            return GameChallenge(title: title, description: description, station: station, line: line, canFail: canFail)
        }

        completion(challenges)
    }
}
