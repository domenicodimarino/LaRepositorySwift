import SwiftUI
import CoreLocation
import UserNotifications

struct ContentView: View {
    let poiList = [
        POI(
            street: "Via Lannio",
            streetNumber: "2",
            city: "Cetara",
            province: "Salerno",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            latitude: nil,         // Se le hai già, mettile qui
            longitude: nil
        ),
        POI(
            street: "Via Giuseppe Armenante",
            streetNumber: "21",
            city: "Cava de' Tirreni",
            province: "Salerno",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            latitude: 40.703582,         // Idem
            longitude: 14.690824
        ),
        POI(
            street: "Via Giovanni Paolo II",
            streetNumber: "132",
            city: "Fisciano",
            province: "Salerno",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            latitude: nil,
            longitude: nil
        )
    ]

    @State private var mappedPOIs: [MappedPOI] = []
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = AvatarViewModel()
    @StateObject private var badgeManager = BadgeManager()

    var body: some View {
        TabView {
            MapTab(pois: mappedPOIs)
                .environmentObject(locationManager)
                .tabItem {
                    Image(systemName: "map")
                    Text("Mappa")
                }
            PlacesList()
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("Diario")
                }
            BadgeView(manager: badgeManager)
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Badge")
                }
            ShopView(avatarViewModel: viewModel)
                .tabItem {
                    Image(systemName: "cart")
                    Text("Shop")
                }
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profilo")
                }
        }
        .onAppear {
            notificationManager.requestPermissions()
            locationManager.requestAuthorization()

            // Mappatura diretta per POI già con coordinate
            let withCoords = poiList.compactMap { poi -> MappedPOI? in
                if let lat = poi.latitude, let lon = poi.longitude {
                    return MappedPOI(
                        id: poi.id,
                        title: poi.title,
                        address: poi.address,
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        isDiscovered: poi.isDiscovered,
                        discoveredTitle: poi.discoveredTitle,
                        photo: poi.photo
                    )
                }
                return nil
            }

            // POI senza coordinate: geocodifica solo quelli
            let withoutCoords = poiList.filter { $0.latitude == nil || $0.longitude == nil }
            if !withoutCoords.isEmpty {
                POIGeocoder.geocode(pois: withoutCoords) { mapped in
                    // Combina POI già mappati + quelli geocodificati
                    self.mappedPOIs = withCoords + mapped
                    locationManager.startMonitoringPOIs(pois: self.mappedPOIs)
                }
            } else {
                self.mappedPOIs = withCoords
                locationManager.startMonitoringPOIs(pois: withCoords)
            }
        }
    }
}
