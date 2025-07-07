//
//  DiaryView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 04/07/25.
//

import SwiftUI

struct DiaryView: View {
    let place: Place
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Immagine principale
                AsyncImage(url: URL(string: place.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(height: 250)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(height: 250)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    // Titolo
                    Text(place.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Informazioni rapide
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Costruzione")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(place.yearBuilt)
                                .font(.headline)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack(alignment: .leading) {
                            Text("Posizione")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(place.location)
                                .font(.headline)
                        }
                    }
                    .padding(.vertical, 5)
                    
                    Divider()
                    
                    // Sezione Diary/Storia
                    Text("Diary")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 5)
                    
                    Text(place.history)
                        .font(.body)
                        .lineSpacing(5)
                    
                    // Data di visita (simulata)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Data della mia visita")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("2025-07-07")
                            .font(.headline)
                    }
                    .padding(.top, 15)
                    
                    // Firma con nome utente
                    Text("Aggiunto da: FrancescoDiCrescenzo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 30)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Diary")
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
    }
}

// Anteprima per SwiftUI Canvas
struct DiaryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DiaryView(place: PlacesData.shared.places[0])
        }
    }
}
