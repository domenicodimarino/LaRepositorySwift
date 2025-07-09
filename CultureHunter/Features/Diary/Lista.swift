import SwiftUI

struct PlacesList: View {
    let places = PlacesData.shared.places
    
    var body: some View {
        NavigationView {
            List(places) { place in
                NavigationLink(destination: DiaryView(place: place)) {
                    HStack {
                        Image(place.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Text(place.name)
                            .font(.headline)
                            .padding(.leading, 10)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
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

// Anteprima per SwiftUI Canvas
struct PlacesList_Previews: PreviewProvider {
    static var previews: some View {
        PlacesList()
    }
}
