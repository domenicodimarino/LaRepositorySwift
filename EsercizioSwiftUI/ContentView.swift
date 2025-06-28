import SwiftUI

struct ContentView: View {
    @State private var shouldCenterUser = false
    @State private var trackingState: TrackingState = .none

    var body: some View {
        ZStack {
            CustomMapView(shouldCenterUser: $shouldCenterUser, trackingState: $trackingState)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    TrackingButton(trackingState: $trackingState) {
                        shouldCenterUser = true
                        trackingState = .follow
                    }
                    .padding(.top, 70)
                    .padding(.trailing, 14)
                }
                Spacer()
            }
        }
    }
}
