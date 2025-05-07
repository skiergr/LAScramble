//
//  FirebaseTestView.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/4/25.
//

import SwiftUI
import FirebaseFirestore

struct FirebaseTestView: View {
    @State private var message = "Waiting to write..."

    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .padding()

            Button("Write Test to Firestore") {
                let db = Firestore.firestore()
                db.collection("test").addDocument(data: [
                    "timestamp": Timestamp(),
                    "message": "Hello from LA Scramble!"
                ]) { error in
                    if let error = error {
                        message = "Error: \(error.localizedDescription)"
                    } else {
                        message = "Firestore write successful!"
                    }
                }
            }
        }
        .padding()
    }
}
