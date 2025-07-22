import SwiftUI
import CoreLocation
import UserNotifications

struct ContentView: View {
    let poiList = [
        POI(
            street: "Via Giuseppe Armenante",
            streetNumber: "21",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Casa mia",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.70355755997264,
            longitude: 14.690757149236486,
            imageName: "casa_mia"
        ),
        POI(
            street: "Via Lannio",
            streetNumber: "2",
            city: "Cetara",
            province: "Salerno",
            diaryPlaceName: "Torre di Cetara",
            isDiscovered: true,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.646993,
            longitude: 14.703472,
            imageName: "torre_di_cetara"
        ),
        POI(
            street: "Castello di Arechi, Fossato degli Aragonesi",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Castello di Arechi",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.684072,
            longitude: 14.755469,
            imageName: "castello_arechi"
        ),
        POI(
            street: "Giardino della Minerva",
            streetNumber: "1",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Giardino della Minerva",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.681106,
            longitude: 14.753674,
            imageName: "giardino_minerva"
        ),
        POI(
            street: "Porto di Salerno, Molo Manfredi",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Porto di Salerno",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.671686,
            longitude: 14.73752,
            imageName: "porto_salerno"
        ),
        POI(
            street: "Chiesa di San Giorgio, Via Duomo",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Chiesa di San Giorgio",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.678821,
            longitude: 14.758956,
            imageName: "chiesa_sangiorgio"
        ),
        POI(
            street: "Piazza della Libertà",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Piazza della Libertà",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.676276,
            longitude: 14.753785,
            imageName: "piazza_liberta"
        ),
        POI(
            street: "Museo Diocesano San Matteo, Largo Plebiscito",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Museo Diocesano San Matteo",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.680618,
            longitude: 14.760391,
            imageName: "museo_diocesano_salerno"
        ),
        POI(
            street: "Cattedrale di Salerno - Duomo, Via Nicola Monterisi",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Duomo di Salerno",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.680203,
            longitude: 14.759559,
            imageName: "duomo_salerno"
        ),
        POI(
            street: "Chiesa di Saragnano",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Chiesa di Saragnano",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.68074,
            longitude: 14.73872,
            imageName: "saragnano"
        ),
        POI(
            street: "Chiesa del Monte dei Morti",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Chiesa del Monte dei Morti",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.680833,
            longitude: 14.760699,
            imageName: "chiesa_monte_morti"
        ),
        POI(
            street: "Teatro Verdi, Piazza Matteo Luciani",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Teatro Verdi",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.67921,
            longitude: 14.75267,
            imageName: "teatro_verdi"
        ),
        POI(
            street: "Via Velia",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Acquedotto Medievale",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.679625,
            longitude: 14.764848,
            imageName: "velia"
        ),
        POI(
            street: "Museo dello Sbarco e Salerno Capitale",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Museo dello Sbarco e Salerno Capitale",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.64696,
            longitude: 14.817397,
            imageName: "museo_sbarco"
        ),
        POI(
            street: "Museo virtuale della scuola medica salernitana",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Museo virtuale della scuola medica salernitana",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.679046,
            longitude: 14.760005,
            imageName: "museo_virtuale"
        ),
        POI(
            street: "Museo Archeologico Provinciale, Via San Benedetto",
            streetNumber: "28",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Museo archeologico provinciale di Salerno",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.678984,
            longitude: 14.762344,
            imageName: "museo_archeologico"
        ),
        POI(
            street: "Chiesa della Santissima Annunziata, Via Luigi Einaudi",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Chiesa della Santissima Annunziata",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.679349,
            longitude: 14.753966,
            imageName: "chiesa_ssannunziata"
        ),
        POI(
            street: "Parrocchia di San Pietro Apostolo, Corso Garibaldi",
            streetNumber: "",
            city: "Cetara",
            province: "Salerno",
            diaryPlaceName: "Parrocchia di San Pietro Apostolo",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.647154,
            longitude: 14.701637,
            imageName: "chiesa_sanpietro"
        ),
        POI(
            street: "Chiesa di Santa Maria di Costantinopoli, Corso di Cetara",
            streetNumber: "",
            city: "Cetara",
            province: "Salerno",
            diaryPlaceName: "Chiesa di Santa Maria di Costantinopoli",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.651264,
            longitude: 14.697518,
            imageName: "costantinopoli"
        ),
        POI(
            street: "Piazza San Francesco",
            streetNumber: "",
            city: "Cetara",
            province: "Salerno",
            diaryPlaceName: "Chiesa di San Francesco",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.647333,
            longitude: 14.700893,
            imageName: "piazza_sanfra"
        ),
        POI(
            street: "Fabbrica Nettuno, Corso Umberto I",
            streetNumber: "",
            city: "Cetara",
            province: "Salerno",
            diaryPlaceName: "Fabbrica Nettuno",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.646787,
            longitude: 14.700531,
            imageName: "fabbrica_nettuno"
        ),
        POI(
            street: "Piazza Eugenio Abbro",
            streetNumber: "",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Monumento ai Caduti",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.700247,
            longitude: 14.706409,
            imageName: "caduti"
        ),
        POI(
            street: "Via Alfonso Balzico",
            streetNumber: "",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Duomo di Cava",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.700062,
            longitude: 14.707315,
            imageName: "duomo_cava"
        ),
        POI(
            street: "Via Armando Diaz",
            streetNumber: "",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Chiesa di San Rocco",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.700954,
            longitude: 14.707278,
            imageName: "chiesa_sanrocco"
        ),
        POI(
            street: "Giardini di San Giovanni, Via Antonio Nigro",
            streetNumber: "",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Giardini di San Giovanni",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.698777,
            longitude: 14.709424,
            imageName: "giardini_sangio"
        ),
        POI(
            street: "Via Canonico Aniello Avallone",
            streetNumber: "",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Chiesa di Maria Assunta in Cielo (Purgatorio)",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.698125,
            longitude: 14.709047,
            imageName: "purgatorio"
        ),
        POI(
            street: "Via Canale",
            streetNumber: "",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Santuario Francescano S.Francesco e S.Antonio",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.695865,
            longitude: 14.71005,
            imageName: "santuario"
        ),
        POI(
            street: "Via Enrico de Marinis",
            streetNumber: "",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Chiesa di Santa Maria Incoronata dell'Olmo",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.695771,
            longitude: 14.711024,
            imageName: "madonna_olmo"
        ),
        POI(
            street: "Via Antonio d'Amico",
            streetNumber: "",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Abbazia della Santissima Trinità",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.682057,
            longitude: 14.691142,
            imageName: "abbazia"
        ),
        POI(
            street: "Strada Provinciale 75",
            streetNumber: "",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Chiesa dell'Avvocatella",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.685062,
            longitude: 14.703943,
            imageName: "chiesa_avvocatella"
        ),
        POI(
            street: "Via Orilia",
            streetNumber: "",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Chiesa di San Lorenzo",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.701055,
            longitude: 14.714703,
            imageName: "chiesa_sanlo"
        ),
        POI(
            street: "Viale Francesco Crispi",
            streetNumber: "",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Villa Comunale Falcone e Borsellino",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.700793,
            longitude: 14.70529,
            imageName: "villa_comunale"
        ),
        POI(
            street: "Via Eduardo de Filippis",
            streetNumber: "171",
            city: "Cava de' Tirreni",
            province: "Salerno",
            diaryPlaceName: "Casa del Dom",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.70847523801939,
            longitude: 14.709200325060241,
            imageName: "villa_comunale"
        ),
        POI(
            street: "Piazzale Alberto Piccinini",
            streetNumber: "",
            city: "Salerno",
            province: "Salerno",
            diaryPlaceName: "Stadio Arechi",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.645228,
            longitude: 14.822551,
            imageName: "stadio_arechi"
        ),
        POI(
            street: "Via del Diritto",
            streetNumber: "",
            city: "Fisciano",
            province: "Salerno",
            diaryPlaceName: "UNISA Edificio E",
            isDiscovered: false,
            discoveredTitle: nil,
            photo: nil,
            photoPath: nil,
            latitude: 40.77252,
            longitude: 14.79116,
            imageName: "villa_comunale"
        )
    ]
        @ObservedObject var avatarViewModel: AvatarViewModel
    @StateObject private var poiViewModel = POIViewModel()
        @StateObject private var notificationManager = NotificationManager()
        @StateObject private var locationManager = LocationManager()
        
        @StateObject private var badgeManager = BadgeManager()
        @StateObject private var missionViewModel = MissionViewModel()

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

                BadgeView(manager: badgeManager)
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
                poiViewModel.geocodeAll(pois: poiList)
            }
            .onReceive(poiViewModel.$mappedPOIs) { mapped in
                locationManager.startMonitoringPOIs(pois: mapped)
            }
        }
}
