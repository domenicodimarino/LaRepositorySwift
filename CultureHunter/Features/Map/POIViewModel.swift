//
//  POIViewModel.swift
//  CultureHunter
//
//  Created by Giovanni Adinolfi   on 04/07/25.
//
import Foundation

class POIViewModel: ObservableObject {
    @Published var mappedPOIs: [MappedPOI] = []
    
    func geocodeAll(pois: [POI]) {
        POIGeocoder.geocode(pois: pois) { mapped in
            DispatchQueue.main.async {
                self.mappedPOIs = mapped
            }
        }
    }
}
