//
//  RulesView.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/6/25.
//

import SwiftUI

struct RulesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📜 Rules")
                .font(.largeTitle)
                .padding(.bottom)

            Text("1. Teams must travel only by LA Metro.")
            Text("2. Complete challenges to control stations.")
            Text("3. You cannot complete a challenge another team has finished.")
            Text("4. The game ends when the timer runs out.")
            Text("5. Have fun and stay safe!")

            Spacer()
        }
        .padding()
        .navigationTitle("Rules")
    }
}
