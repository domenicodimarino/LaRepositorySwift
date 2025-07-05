import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let notificationManager = NotificationManager()
    private var notifiedPOIs: Set<String> = [] // Per evitare notifiche ripetute

    @Published var lastLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    var poiList: [POI] = []

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    // Chiamala quando sai che l’utente è vicino a un POI!
    func userIsNearPOI(poiID: String) {
        // (opzionale: verifica che il POI esista nella lista)
        guard poiList.contains(where: { $0.id.uuidString == poiID }) else { return }
        if !notifiedPOIs.contains(poiID) {
            notificationManager.sendPOINearbyNotificationWithImage()
            notifiedPOIs.insert(poiID)
        }
    }

    func resetPOINotification(poiID: String) {
        // Se vuoi permettere una nuova notifica per questo POI (ad esempio quando l'utente si allontana)
        notifiedPOIs.remove(poiID)
    }

    // Location delegate base (può essere lasciato così, oppure tolto se non ti serve la posizione)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
}
