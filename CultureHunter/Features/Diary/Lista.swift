import SwiftUI

struct PlacesList: View {
    let places: [MappedPOI]
    
    var body: some View {
        NavigationView {
            List(places) { place in
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
