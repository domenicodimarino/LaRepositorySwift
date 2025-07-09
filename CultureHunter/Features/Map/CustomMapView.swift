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
        mapView.preferredConfiguration = configuration
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.delegate = context.coordinator

        // Camera 3D iniziale (solo qui!)
        let coordinate = CLLocationCoordinate2D(latitude: 40.7083, longitude: 14.7088)
        let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 600, pitch: 75, heading: 0)
        mapView.setCamera(camera, animated: false)

        for poi in mappedPOIs {
            let annotation = MappedPOIAnnotation(poi: poi)
            mapView.addAnnotation(annotation)
        }
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Cambia solo tracking mode, NON la camera!
        switch trackingState {
        case .follow:
            if uiView.userTrackingMode != .follow {
                uiView.setUserTrackingMode(.follow, animated: true)
            }
        case .none:
            if uiView.userTrackingMode != .none {
                uiView.setUserTrackingMode(.none, animated: true)
                // Dopo che il tracking si disattiva, puoi rimettere la camera 3D.
                let coordinate = CLLocationCoordinate2D(latitude: 40.7083, longitude: 14.7088)
                let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 600, pitch: 75, heading: 0)
                uiView.setCamera(camera, animated: true)
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

        // RIMUOVI tutte le altre funzioni delegate che impostano la camera!
        // NON mettere regionDidChangeAnimated né didUpdate userLocation!

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

class MappedPOIAnnotation: NSObject, MKAnnotation {
    let poi: MappedPOI
    var coordinate: CLLocationCoordinate2D { poi.coordinate }
    var title: String? { poi.title }
    init(poi: MappedPOI) { self.poi = poi }
}

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
