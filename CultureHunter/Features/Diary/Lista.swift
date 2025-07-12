import SwiftUI

struct PlacesList: View {
    let places: [MappedPOI]

    @State private var selectedCity: String = "Tutti"

    // Ricava automaticamente tutte le città presenti
    private var allCities: [String] {
        let cities = Set(places.map { $0.city })
        return ["Tutti"] + cities.sorted()
    }

    // Filtra i POI per città selezionata
    private var filteredPlaces: [MappedPOI] {
        if selectedCity == "Tutti" {
            return places
        } else {
            return places.filter { $0.city == selectedCity }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Filtra città", selection: $selectedCity) {
                    ForEach(allCities, id: \.self) { city in
                        Text(city).tag(city)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                List(filteredPlaces) { place in
                    if place.isDiscovered {
                        NavigationLink(destination: DiaryView(poi: place)) {
                            PlacesListRow(place: place)
                        }
                    } else {
                        PlacesListRow(place: place)
                            .contentShape(Rectangle())
                            .disabled(true)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Diario")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
            }
        }
    }
}

struct PlacesListRow: View {
    let place: MappedPOI

    var body: some View {
        HStack(spacing: 16) {
            if place.isDiscovered, let photoPath = place.photoPath, let img = UIImage(contentsOfFile: photoPath) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(place.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .grayscale(1.0)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(place.isDiscovered ? place.diaryPlaceName : "?")
                    .font(.headline)
                if let date = place.discoveredDate, place.isDiscovered {
                    Text(formatDate(date))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            if place.isDiscovered {
                Text("Info")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}
