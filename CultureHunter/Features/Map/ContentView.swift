import SwiftUI
import CoreLocation
import UserNotifications
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context

    @StateObject private var avatarViewModel = AvatarViewModel()
    @StateObject private var poiViewModel: POIViewModel
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var badgeManager = BadgeManager()
    @StateObject private var missionViewModel = MissionViewModel()

    // Inizializzatore per passare il context a POIViewModel
    init(avatarViewModel: AvatarViewModel) {
        _avatarViewModel = StateObject(wrappedValue: avatarViewModel)
        // 👇 PRIMA inserisci i POI iniziali!
                POIPersistenceManager.shared.bootstrapInitialPOIsIfNeeded(context: PersistenceController.shared.container.viewContext)
                // 👇 POIViewModel trova già i POI nel DB
                _poiViewModel = StateObject(wrappedValue: POIViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        TabView {
            MapTab(
                viewModel: poiViewModel,
                badgeManager: badgeManager,
                avatarViewModel: avatarViewModel,
                missionViewModel: missionViewModel
            )
            .environmentObject(locationManager)
            .tabItem {
                Image(systemName: "map")
                Text("Mappa")
            }

            PlacesList(places: poiViewModel.mappedPOIs, viewModel: poiViewModel)
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("Diario")
                }

            BadgeView(manager: badgeManager, allMappedPOIs: poiViewModel.mappedPOIs)
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Badge")
                }

            ShopView(avatarViewModel: avatarViewModel, missionViewModel: missionViewModel)
                .tabItem {
                    Image(systemName: "cart")
                    Text("Shop")
                }

            ProfileView(viewModel: avatarViewModel)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profilo")
                }
        }
        .onAppear {
            missionViewModel.setAvatarViewModel(avatarViewModel)
            notificationManager.requestPermissions()
            locationManager.requestAuthorization()
        }
        .onReceive(poiViewModel.$mappedPOIs) { mapped in
            locationManager.setAllPOIs(mapped)
        }
    }
}
