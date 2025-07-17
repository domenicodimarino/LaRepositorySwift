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
                        showPhotoButton = poi != nil ? shouldShowPhotoButton(for: poi!) : false
                    },
                    userLocation: locationManager.lastLocation
                )
                .edgesIgnoringSafeArea(.top)
            } else {
                ProgressView("Caricamento POI sulla mappa…")
                    .edgesIgnoringSafeArea(.top)
            }
            // Popup SCATTA
            if showPhotoButton, let poi = selectedPOI, !poi.isDiscovered {
                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        HStack {
                            Text("📍")
                                .font(.system(size: 32))
                            Text("Sei vicino a \(poi.diaryPlaceName)!")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top, 12)

                        Text("Aggiungilo al tuo diario scattando una foto!")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)

                        Button(action: {
                            showCamera = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 28)
                                    .foregroundColor(.blue)
                                Text("SCATTA")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 32)
                            .background(Color.black)
                            .cornerRadius(28)
                            .shadow(radius: 6, y: 4)
                        }
                        .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.black.opacity(0.85))
                            .shadow(radius: 8)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 60)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: showPhotoButton)
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
                return userLoc.distance(from: poiLoc) < 20
            }
        }
