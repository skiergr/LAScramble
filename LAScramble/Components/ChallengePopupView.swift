import SwiftUI

struct ChallengePopupView: View {
    let challenge: GameChallenge
    var onComplete: () -> Void
    var onSacrifice: () -> Void
    var onClose: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text(challenge.title)
                    .font(.title2)
                    .bold()

                Text(challenge.station)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(challenge.description)
                    .font(.body)
                    .padding(.horizontal)

                Button("✅ Mark as Complete") {
                    onComplete()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("⚠️ Sacrifice This Challenge") {
                    onSacrifice()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        onClose()
                    }
                }
            }
        }
    }
}
