import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    private var notificationManager = NotificationManager()
    
    private var allPOIs: [MappedPOI] = []    // Tutti i POI disponibili nel gioco
    private(set) var monitoredPOIs: [MappedPOI] = [] // Quelli attualmente monitorati

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }

    func requestAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    /// Chiamata con la lista completa dei POI (da ContentView)
    func setAllPOIs(_ pois: [MappedPOI]) {
        allPOIs = pois
        updateMonitoredPOIs()
    }

    /// Aggiorna la lista dei POI monitorati in base alla posizione attuale
    func updateMonitoredPOIs() {
        guard let userLoc = lastLocation else { return }
        
        // Escludi quelli già scoperti
        let undiscovered = allPOIs.filter { !$0.isDiscovered }
        // Ordina per distanza
        let sorted = undiscovered.sorted {
            userLoc.distance(from: CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)) <
            userLoc.distance(from: CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude))
        }
        // Tieni i 20 più vicini
        let toMonitor = Array(sorted.prefix(20))
        // Se sono diversi da quelli già monitorati, aggiorna
        if toMonitor.map(\.id) != monitoredPOIs.map(\.id) {
            startMonitoringPOIs(pois: toMonitor)
        }
    }

    func startMonitoringPOIs(pois: [MappedPOI]) {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
        monitoredPOIs = pois
        for poi in pois {
            let region = CLCircularRegion(center: poi.coordinate, radius: 100, identifier: poi.id.uuidString)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            manager.startMonitoring(for: region)
        }
        print("Regioni monitorate ora: \(manager.monitoredRegions.count)")
        for region in manager.monitoredRegions {
            if let circular = region as? CLCircularRegion {
                print(" - \(circular.identifier) center: \(circular.center) radius: \(circular.radius)")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, newLocation.horizontalAccuracy >= 0 else { return }
        lastLocation = newLocation
        updateMonitoredPOIs()
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let poi = monitoredPOIs.first(where: { $0.id.uuidString == region.identifier }) {
            notificationManager.sendPOINearbyNotificationWithImage(for: poi)
        } else {
            notificationManager.sendPOINearbyNotificationWithImage()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            manager.requestLocation()
        case .denied, .restricted:
            manager.stopUpdatingLocation()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
