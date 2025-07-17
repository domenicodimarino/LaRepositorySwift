import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    private var notificationManager = NotificationManager()
    
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
    }

    func startMonitoringPOIs(pois: [MappedPOI]) {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
        monitoredPOIs = pois
        for poi in pois {
            let region = CLCircularRegion(center: poi.coordinate, radius: 50, identifier: poi.id.uuidString)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            manager.startMonitoring(for: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, newLocation.horizontalAccuracy >= 0 else { return }
        lastLocation = newLocation
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
        case .denied, .restricted:
            manager.stopUpdatingLocation()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
