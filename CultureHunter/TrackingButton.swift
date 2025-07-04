import SwiftUI

enum TrackingState {
    case none
    case follow
}

struct TrackingButton: View {
    @Binding var trackingState: TrackingState
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "location")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(trackingState == .follow ? Color.blue : Color(white: 0.7))
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 2)
        }
        .accessibilityLabel(trackingState == .follow ? "Sta seguendo la mia posizione" : "Centra sulla mia posizione")
    }
}
