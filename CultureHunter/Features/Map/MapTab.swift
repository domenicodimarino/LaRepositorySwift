//
//  MapTab.swift
//  CultureHunter
//
//  Created by Giovanni Adinolfi   on 04/07/25.
//
import SwiftUI

struct MapTab: View {
    let pois: [POI]
    @State private var shouldCenterUser = false
    @State private var trackingState: TrackingState = .none
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = POIViewModel()
    
    var body: some View {
        ZStack {
            if !viewModel.mappedPOIs.isEmpty {
                CustomMapView(
                    shouldCenterUser: $shouldCenterUser,
                    trackingState: $trackingState,
                    mappedPOIs: viewModel.mappedPOIs
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
            viewModel.geocodeAll(pois: pois)
        }
    }
}
