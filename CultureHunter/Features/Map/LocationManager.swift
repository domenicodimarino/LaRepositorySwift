import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    private var notificationManager = NotificationManager()
    
    // Mantieni la lista dei POI monitorati per notifica personalizzata
    private var monitoredPOIs: [MappedPOI] = []

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }

    func requestAuthorization() {
        manager.requestAlwaysAuthorization()
        // Se vuoi solo foreground: manager.requestWhenInUseAuthorization()
    }

    // Avvia il monitoraggio di tutte le regioni dei POI geocodificati
    func startMonitoringPOIs(pois: [MappedPOI]) {
        // Rimuovi eventuali regioni precedenti prima di aggiungerne di nuove
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
        monitoredPOIs = pois // Salva la lista per notifiche personalizzate
        for poi in pois {
            let region = CLCircularRegion(center: poi.coordinate, radius: 50, identifier: poi.id.uuidString)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            manager.startMonitoring(for: region)
        }
    }

    // Delegate: posizione aggiornata
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    // Delegate: entrato in una regione
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entrato in regione: \(region.identifier)")
        // Cerca il POI corrispondente
        if let poi = monitoredPOIs.first(where: { $0.id.uuidString == region.identifier }) {
            notificationManager.sendPOINearbyNotificationWithImage(for: poi)
        } else {
            // Fallback se il POI non viene trovato
            notificationManager.sendPOINearbyNotificationWithImage()
        }
    }

    // Delegate: errori
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    // Delegate: autorizzazioni cambiate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Autorizzazione posizione: CONSENTITA")
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Autorizzazione posizione NEGATA o limitata")
            manager.stopUpdatingLocation()
        case .notDetermined:
            print("Autorizzazione posizione non ancora richiesta")
        @unknown default:
            print("Autorizzazione posizione: stato sconosciuto")
        }
    }
}
