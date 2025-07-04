//
//  POIDetailView.swift
//  CultureHunter
//
//  Created by Giovanni Adinolfi   on 04/07/25.
//
import SwiftUI

struct POIDetailView: View {
    let poi: POI
    
    var body: some View {
        VStack(spacing: 24) {
            if poi.isDiscovered {
                // POI scoperto
                if let image = poi.photo {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(16)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .padding()
                }
                Text(poi.discoveredTitle ?? "Punto scoperto")
                    .font(.title).bold()
                Text(poi.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                // Qui puoi aggiungere badge, diario, ecc.
            } else {
                // POI misterioso
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                Text("Punto di interesse misterioso")
                    .font(.title2).bold()
                Text("Scopri questo luogo per vedere i dettagli!")
                    .font(.body)
                    .foregroundColor(.secondary)
                Text("\(poi.city), \(poi.province)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Dettaglio POI")
    }
}
