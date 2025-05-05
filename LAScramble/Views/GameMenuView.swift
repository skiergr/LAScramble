//
//  GameMenuView.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/4/25.
//

import SwiftUI

struct GameMenuView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("LA Scramble")
                    .font(.largeTitle)
                    .padding(.top, 40)

                NavigationLink(destination: CreateGameView()) {
                    Text("➕ Create Game")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: JoinGameView()) {
                    Text("🔗 Join Game")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
        }
    }
}
