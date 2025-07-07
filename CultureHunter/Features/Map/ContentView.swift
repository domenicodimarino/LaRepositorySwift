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
        )
    ]

    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = AvatarViewModel()

    var body: some View {
        TabView {
            MapTab(pois: poiList)
                .tabItem {
                    Image(systemName: "map")
                    Text("Mappa")
                }
            Text("Diario")
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("Diario")
                }
            Text("Badge")
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
        }
    }
}
