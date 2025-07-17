import SwiftUI

struct BadgeDetailView: View {
    let badge: BadgeModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(badge.cityName)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 8)

                if !badge.cityStory.isEmpty {
                    Text(badge.cityStory)
                        .font(.title3)
                        .padding(.bottom, 16)
                }

                if !badge.discoveredImageNames.isEmpty {
                    Text("Le tue immagini dei POI")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(badge.discoveredImageNames, id: \.self) { imgName in
                                Image(imgName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                } else {
                    Text("Non hai ancora caricato immagini dei POI.")
                        .foregroundColor(.gray)
                        .italic()
                }

                Spacer()
            }
            .padding()
        }
    }
}
