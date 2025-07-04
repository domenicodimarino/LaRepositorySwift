import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    @Binding var shouldCenterUser: Bool
    @Binding var trackingState: TrackingState

    let configuration: MKStandardMapConfiguration

    init(shouldCenterUser: Binding<Bool>, trackingState: Binding<TrackingState>) {
        self._shouldCenterUser = shouldCenterUser
        self._trackingState = trackingState
        configuration = MKStandardMapConfiguration(elevationStyle: .realistic)
        configuration.pointOfInterestFilter = MKPointOfInterestFilter(including: [])
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()

        let coordinate = CLLocationCoordinate2D(latitude: 40.7083, longitude: 14.7088)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1300, longitudinalMeters: 1300)
        mapView.setRegion(region, animated: false)

        mapView.preferredConfiguration = configuration
        mapView.isPitchEnabled = false
        
        let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 600, pitch: 80, heading: 0)
        mapView.setCamera(camera, animated: false)

        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none // di default non segue l'utente

        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 40.70837020698155, longitude: 14.70882631252605)
        annotation.title = "Punto di interesse"
        mapView.addAnnotation(annotation)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if shouldCenterUser {
            uiView.userTrackingMode = .follow
            if shouldCenterUser {
                DispatchQueue.main.async {
                    self.shouldCenterUser = false
                }
            }
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        init(_ parent: CustomMapView) { self.parent = parent }

        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            DispatchQueue.main.async {
                switch mode {
                case .follow, .followWithHeading:
                    self.parent.trackingState = .follow
                default:
                    self.parent.trackingState = .none
                }
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                let identifier = "UserLocation"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                if view == nil {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                }
                view?.image = UIImage(named: "giovanni")
                view?.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
                return view
            } else {
                let identifier = "CustomMarker"
                var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if markerView == nil {
                    markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    markerView?.canShowCallout = true
                }

                markerView?.markerTintColor = .systemRed
                markerView?.glyphImage = UIImage(systemName: "questionmark")
                markerView?.annotation = annotation
                return markerView
            }
        }
    }
}
