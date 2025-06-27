import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    
    let configuration: MKStandardMapConfiguration

    init() {
        // Configurazione mappa con elevazione realistica
        configuration = MKStandardMapConfiguration(elevationStyle: .realistic)
        configuration.pointOfInterestFilter = MKPointOfInterestFilter(including: [])
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()

        let coordinate = CLLocationCoordinate2D(latitude: 40.7083, longitude: 14.7088)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1300, longitudinalMeters: 1300)
        mapView.setRegion(region, animated: false)

        // Applica la configurazione realistica
        mapView.preferredConfiguration = configuration

        // Inclinazione 3D di default
        let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 600, pitch: 60, heading: 0)
        mapView.setCamera(camera, animated: false)

        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        // Aggiungi un marker
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 40.707, longitude: 14.708)
        annotation.title = "Punto di interesse"
        mapView.addAnnotation(annotation)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Nessun aggiornamento dinamico necessario
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                // Personalizza la posizione dell'utente
                let identifier = "UserLocation"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                if view == nil {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                }
                view?.image = UIImage(named: "giovanni") // tua immagine
                view?.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
                return view
            } else {
                let identifier = "CustomMarker"
                var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if markerView == nil {
                    markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    markerView?.canShowCallout = true
                    markerView?.markerTintColor = .systemRed
                    markerView?.glyphImage = UIImage(systemName: "questionmark")
                } else {
                    markerView?.annotation = annotation
                }
                return markerView
            }
        }
    }
}
