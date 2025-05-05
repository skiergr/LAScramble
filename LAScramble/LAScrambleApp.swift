//
//  LAScrambleApp.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/4/25.
//

import SwiftUI
import Firebase

@main
struct LAScrambleApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            UsernameLoginView()
        }
    }
}
