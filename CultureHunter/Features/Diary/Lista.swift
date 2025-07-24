import SwiftUI

struct PlacesList: View {
    let places: [MappedPOI]

    @State private var selectedCity: String = "Tutti"
    @ObservedObject var viewModel: POIViewModel

    private var allCities: [String] {
        let cities = Set(places.map { $0.city })
        return ["Tutti"] + cities.sorted()
    }

    private var filteredPlaces: [MappedPOI] {
        let baseList: [MappedPOI]
        if selectedCity == "Tutti" {
            baseList = places
        } else {
            baseList = places.filter { $0.city == selectedCity }
        }
        let discovered = baseList.filter { $0.isDiscovered }
        let notDiscovered = baseList.filter { !$0.isDiscovered }
        return discovered + notDiscovered
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(allCities, id: \.self) { city in
                                Button(action: {
                                    selectedCity = city
                                }) {
                                    Text(city)
                                        .fontWeight(selectedCity == city ? .bold : .regular)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 20)
                                        .background(selectedCity == city ? Color.black.opacity(0.4) : Color(.systemGray6))
                                        .foregroundColor(selectedCity == city ? .white : .primary)
                                        .cornerRadius(16)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    List(filteredPlaces) { place in
                        if place.isDiscovered {
                            NavigationLink(destination: DiaryView(poi: place, viewModel: viewModel)) {
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
        .navigationViewStyle(.stack)
    }
}

struct PlacesListRow: View {
    let place: MappedPOI

    var body: some View {
        HStack(spacing: 16) {
            if place.isDiscovered, let img = place.photo {
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
