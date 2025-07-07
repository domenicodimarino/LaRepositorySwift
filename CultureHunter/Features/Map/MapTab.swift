import SwiftUI

struct MapTab: View {
    let pois: [MappedPOI]
    @State private var shouldCenterUser = false
    @State private var trackingState: TrackingState = .none
    @StateObject private var locationManager = LocationManager()
    @State private var hasCenteredOnUser = false

    var body: some View {
        ZStack {
            if !pois.isEmpty {
                CustomMapView(
                    shouldCenterUser: $shouldCenterUser,
                    trackingState: $trackingState,
                    mappedPOIs: pois
                )
                .edgesIgnoringSafeArea(.top)
            } else {
                ProgressView("Caricamento POI sulla mappa…")
                    .edgesIgnoringSafeArea(.top)
            }
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
        .onAppear {
            locationManager.requestAuthorization()
        }
        .onChange(of: locationManager.lastLocation) { newLocation in
            if newLocation != nil && !hasCenteredOnUser {
                shouldCenterUser = true
                hasCenteredOnUser = true
            }
        }
    }
}
