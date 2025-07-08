import SwiftUI

struct MapTab: View {
    let pois: [MappedPOI]
    @State private var trackingState: TrackingState = .none
    @StateObject private var locationManager = LocationManager()
    @State private var hasCenteredOnUser = false

    var body: some View {
        ZStack {
            if !pois.isEmpty {
                CustomMapView(
                    shouldCenterUser: .constant(false), // non più necessario, tutto gestito da trackingState
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
                trackingState = .follow
                hasCenteredOnUser = true
            }
        }
    }
}
