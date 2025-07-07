import SwiftUI

struct ContentView: View {
    // Lista di POI originali (senza coordinate)
    let poiList = [
        POI(
            street: "Via Lannio",
            streetNumber: "2",
            city: "Cetara",
            province: "Salerno",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil
        ),
        POI(
            street: "Via Giuseppe Armenante",
            streetNumber: "21",
            city: "Cava de' Tirreni",
            province: "Salerno",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil
        ),
        POI(
            street: "Via Giovanni Paolo II",
            streetNumber: "132",
            city: "Fisciano",
            province: "Salerno",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil
        )
    ]
    
    @State private var mappedPOIs: [MappedPOI] = []
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var badgeManager = BadgeManager()

    var body: some View {
        TabView {
            MapTab(pois: mappedPOIs)
                .environmentObject(locationManager)
                .tabItem {
                    Image(systemName: "map")
                    Text("Mappa")
                }
            // Diario con collegamento a DiaryView
            NavigationStack {
                List(PlacesData.shared.places) { place in
                    NavigationLink(destination: DiaryView(place: place)) {
                        Text(place.name)
                    }
                }
                .navigationTitle("Diario")
            }
            .tabItem {
                Image(systemName: "book.closed")
                Text("Diario")
            }
            BadgeView(manager: badgeManager)
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Badge")
                }
            Text("Shop")
                .tabItem {
                    Image(systemName: "cart")
                    Text("Shop")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profilo")
                }
        }
        .onAppear {
            notificationManager.requestPermissions()
            locationManager.requestAuthorization()
            POIGeocoder.geocode(pois: poiList) { mapped in
                self.mappedPOIs = mapped
                locationManager.startMonitoringPOIs(pois: mapped)
            }
        }
    }
}
