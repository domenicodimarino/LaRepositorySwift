import SwiftUI
import CoreLocation

struct MapTab: View {
    @ObservedObject var viewModel: POIViewModel
    @ObservedObject var badgeManager: BadgeManager
    @ObservedObject var avatarViewModel: AvatarViewModel
    @ObservedObject var missionViewModel: MissionViewModel

    @State private var trackingState: TrackingState = .none
    @StateObject private var locationManager = LocationManager()
    @State private var hasCenteredOnUser = false

    @State private var selectedPOI: MappedPOI?
    @State private var showPhotoButton = false
    @State private var showCamera = false

    var body: some View {
        ZStack {
            if !viewModel.mappedPOIs.isEmpty {
                CustomMapView(
                    trackingState: $trackingState,
                    mappedPOIs: viewModel.mappedPOIs,
                    avatarViewModel: avatarViewModel,
                    onPOISelected: { poi in
                        selectedPOI = poi
                        showPhotoButton = shouldShowPhotoButton(for: poi)
                    },
                    userLocation: locationManager.lastLocation // <-- PASSA QUESTO!
                )
                .edgesIgnoringSafeArea(.top)
            } else {
                ProgressView("Caricamento POI sulla mappa…")
                    .edgesIgnoringSafeArea(.top)
            }

            if showPhotoButton, let poi = selectedPOI, !poi.isDiscovered {
                VStack {
                    Spacer()
                    Button(action: {
                        showCamera = true
                    }) {
                        Label("Scatta", systemImage: "camera.fill")
                            .padding()
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            if let poi = selectedPOI {
                CameraPicker { image in
                    viewModel.markPOIDiscovered(
                        id: poi.id,
                        photo: image,
                        city: poi.city,
                        badgeManager: badgeManager,
                        nomeUtente: "Giovanni"
                    )
                    if let reward = missionViewModel.tryCompleteMission(poiVisited: true) {
                        avatarViewModel.addCoins(reward)
                    }
                }
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

    private func shouldShowPhotoButton(for poi: MappedPOI) -> Bool {
        guard let userLoc = locationManager.lastLocation else { return false }
        let poiLoc = CLLocation(latitude: poi.coordinate.latitude, longitude: poi.coordinate.longitude)
        return userLoc.distance(from: poiLoc) < 100
    }
}
