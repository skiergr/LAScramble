import SwiftUI

struct ChallengePopupView: View {
    let challenge: GameChallenge
    var onComplete: () -> Void
    var onClose: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Text(challenge.title)
                    .font(.title2)
                    .bold()

                Text("📍 \(challenge.station)")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(challenge.description)
                    .font(.body)
                    .padding()

                Button("✅ Mark as Complete") {
                    onComplete()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
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
