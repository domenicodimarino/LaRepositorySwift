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
            POIGeocoder.geocode(pois: poiList) { mapped in
                self.mappedPOIs = mapped
                locationManager.startMonitoringPOIs(pois: mapped)
            }
        }
    }
}
