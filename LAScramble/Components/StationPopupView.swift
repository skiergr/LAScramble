import SwiftUI

struct StationPopupView: View {
    let station: Station
    @Binding var isVisible: Station?
    var onUnlock: () -> Void
    var alreadyUnlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            Text(station.name)
                .font(.headline)

            if alreadyUnlocked {
                Text("✅ Challenge already unlocked")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                Button("Unlock Challenge") {
                    onUnlock()
                    isVisible = nil
                }
                .padding(6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            Button("Close") {
                isVisible = nil
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 8)
        .frame(width: 250)
        .position(x: 200, y: 150)
    }
}
