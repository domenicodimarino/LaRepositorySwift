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
            diaryPlaceName: "Casa Mia", // esempio: deve combaciare con Place.name
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: nil,
            longitude: nil
        ),
        POI(
            street: "Via Giuseppe Armenante",
            streetNumber: "21",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Casa Mia", // esempio
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.703449251961516,
            longitude: 14.690691949939817
        ),
        POI(
            street: "Via Giovanni Paolo II",
            streetNumber: "132",
            city: "Fisciano",
            province: "Salerno",
            diaryPlaceName: "Casa Mia", // esempio
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: nil,
            longitude: nil
        )
    ]

    @StateObject private var poiViewModel = POIViewModel()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = AvatarViewModel()
    @StateObject private var badgeManager = BadgeManager()

    var body: some View {
        TabView {
            MapTab(viewModel: poiViewModel, badgeManager: badgeManager)
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
            poiViewModel.geocodeAll(pois: poiList)
            // Se vuoi monitorare i POI dopo la geocodifica, fallo in un onReceive nel MapTab o qui, ad esempio:
            locationManager.startMonitoringPOIs(pois: poiViewModel.mappedPOIs)
        }
    }
}
