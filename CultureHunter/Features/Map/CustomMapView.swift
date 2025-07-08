import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    @Binding var shouldCenterUser: Bool
    @Binding var trackingState: TrackingState
    var mappedPOIs: [MappedPOI]

    let configuration: MKStandardMapConfiguration

    init(shouldCenterUser: Binding<Bool>, trackingState: Binding<TrackingState>, mappedPOIs: [MappedPOI]) {
        self._shouldCenterUser = shouldCenterUser
        self._trackingState = trackingState
        self.mappedPOIs = mappedPOIs
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
        mapView.userTrackingMode = .none

        // Aggiungi i POI come annotazioni
        for poi in mappedPOIs {
            let annotation = MKPointAnnotation()
            annotation.coordinate = poi.coordinate
            annotation.title = poi.title
            mapView.addAnnotation(annotation)
        }
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Gestione tracking mode: se trackingState == .follow, segui sempre l'utente
        if trackingState == .follow {
            if uiView.userTrackingMode != .follow {
                uiView.setUserTrackingMode(.follow, animated: true)
            }
        } else {
            if uiView.userTrackingMode != .none {
                uiView.setUserTrackingMode(.none, animated: true)
            }
        }

        // Aggiorna i POI se la lista cambia
        let currentAnnotations = uiView.annotations.filter { !($0 is MKUserLocation) }
        if currentAnnotations.count != mappedPOIs.count ||
            !Set(currentAnnotations.compactMap { $0.title ?? "" }).isSubset(of: Set(mappedPOIs.map { $0.title })) {
            uiView.removeAnnotations(currentAnnotations)
            for poi in mappedPOIs {
                let annotation = MKPointAnnotation()
                annotation.coordinate = poi.coordinate
                annotation.title = poi.title
                uiView.addAnnotation(annotation)
            }
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        private var isRegionChangeFromUserInteraction = false

        init(_ parent: CustomMapView) { self.parent = parent }

        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            // Determina se il cambio regione è dovuto all'interazione utente
            isRegionChangeFromUserInteraction = mapViewIsUserInteraction(mapView)
            // Se è l'utente a muovere la mappa, disattiva il tracking automatico
            if parent.trackingState == .follow && isRegionChangeFromUserInteraction {
                mapView.setUserTrackingMode(.none, animated: true)
                DispatchQueue.main.async {
                    self.parent.trackingState = .none
                }
            }
        }

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
                return nil
            } else {
                let identifier = "POIMarker"
                var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if markerView == nil {
                    markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    markerView?.canShowCallout = true
                }
                markerView?.markerTintColor = .systemRed
                markerView?.glyphText = "?"
                markerView?.annotation = annotation
                return markerView
            }
        }

        // Utility per capire se la regione è cambiata da gesto utente
        private func mapViewIsUserInteraction(_ mapView: MKMapView) -> Bool {
            for view in mapView.subviews {
                if let gestureRecognizers = view.gestureRecognizers {
                    for recognizer in gestureRecognizers {
                        if recognizer.state == .began || recognizer.state == .ended {
                            return true
                        }
                    }
                }
            }
            return false
        }
    }
}
