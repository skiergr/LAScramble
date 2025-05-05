import SwiftUI

struct StationPopupFullScreenView: View {
    let station: Station
    let onUnlock: () -> Void
    let onClose: () -> Void
    let alreadyUnlocked: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(station.name)
                    .font(.largeTitle)
                    .padding(.top)

                if alreadyUnlocked {
                    Text("✅ Challenge already unlocked")
                        .font(.headline)
                        .foregroundColor(.green)
                } else {
                    Button("Unlock Challenge") {
                        onUnlock()
                        onClose()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

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
