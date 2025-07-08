import SwiftUI
import CoreLocation

struct MapTab: View {
    @ObservedObject var viewModel: POIViewModel
    @ObservedObject var badgeManager: BadgeManager

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
                    onPOISelected: { poi in
                        selectedPOI = poi
                        showPhotoButton = shouldShowPhotoButton(for: poi)
                    }
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
            // Bottone scatta solo se vicino e POI non ancora scoperto
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
                    // Aggiorna il POI come scoperto con la foto
                    viewModel.markPOIDiscovered(
                        id: poi.id,
                        photo: image,
                        city: poi.city,
                        badgeManager: badgeManager,
                        nomeUtente: "Giovanni" // O recuperalo dinamicamente dall’utente
                    )
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
        return userLoc.distance(from: poiLoc) < 100 // soglia in metri
    }

    // Helper per estrarre la città dall'indirizzo (adatta se serve!)
    private func cityFromAddress(_ address: String) -> String {
        // Se il formato è sempre "via, città, provincia", puoi splittare su ","
        let comps = address.split(separator: ",")
        return comps.count > 1 ? comps[1].trimmingCharacters(in: .whitespaces) : ""
    }
}
