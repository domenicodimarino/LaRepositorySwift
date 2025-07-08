import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    @Binding var trackingState: TrackingState
    var mappedPOIs: [MappedPOI]
    var onPOISelected: ((MappedPOI) -> Void)? = nil

    let configuration: MKStandardMapConfiguration

    init(trackingState: Binding<TrackingState>, mappedPOIs: [MappedPOI], onPOISelected: ((MappedPOI) -> Void)? = nil) {
        self._trackingState = trackingState
        self.mappedPOIs = mappedPOIs
        self.onPOISelected = onPOISelected
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
            let annotation = MappedPOIAnnotation(poi: poi)
            mapView.addAnnotation(annotation)
        }
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Gestione tracking mode
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
            !Set(currentAnnotations.compactMap { ($0 as? MappedPOIAnnotation)?.poi.id }).isSubset(of: Set(mappedPOIs.map { $0.id })) {
            uiView.removeAnnotations(currentAnnotations)
            for poi in mappedPOIs {
                let annotation = MappedPOIAnnotation(poi: poi)
                uiView.addAnnotation(annotation)
            }
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        private var isRegionChangeFromUserInteraction = false

        init(_ parent: CustomMapView) { self.parent = parent }

        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            isRegionChangeFromUserInteraction = mapViewIsUserInteraction(mapView)
            if parent.trackingState == .follow && isRegionChangeFromUserInteraction {
                mapView.setUserTrackingMode(.none, animated: true)
                DispatchQueue.main.async {
                    self.parent.trackingState = .none
                }
            }
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MappedPOIAnnotation {
                parent.onPOISelected?(annotation.poi)
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            } else if let poiAnnotation = annotation as? MappedPOIAnnotation {
                let identifier = "POIMarker"
                var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if markerView == nil {
                    markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    markerView?.canShowCallout = true
                }
                markerView?.markerTintColor = .systemRed
                if poiAnnotation.poi.isDiscovered, let photo = poiAnnotation.poi.photo {
                    // Ridimensiona la foto per il pin
                    markerView?.glyphImage = photo.resizedToPin()
                    markerView?.glyphText = nil
                } else {
                    markerView?.glyphText = "?"
                    markerView?.glyphImage = nil
                }
                markerView?.annotation = annotation
                return markerView
            }
            return nil
        }

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

// Una annotation custom per collegare il POI all’annotation
class MappedPOIAnnotation: NSObject, MKAnnotation {
    let poi: MappedPOI
    var coordinate: CLLocationCoordinate2D { poi.coordinate }
    var title: String? { poi.title }
    init(poi: MappedPOI) { self.poi = poi }
}

// Estensione per ridimensionare la foto per il pin
extension UIImage {
    func resizedToPin() -> UIImage {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? self
    }
}
