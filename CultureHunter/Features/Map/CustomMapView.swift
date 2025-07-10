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
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.delegate = context.coordinator

        // Camera 3D iniziale
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
        switch trackingState {
        case .follow:
            if uiView.userTrackingMode != .follow {
                uiView.setUserTrackingMode(.follow, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    centerCameraOnUser(uiView)
                }
            }
        case .none:
            if uiView.userTrackingMode != .none {
                uiView.setUserTrackingMode(.none, animated: true)
                let coordinate = CLLocationCoordinate2D(latitude: 40.7083, longitude: 14.7088)
                let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 600, pitch: 75, heading: uiView.camera.heading)
                uiView.setCamera(camera, animated: true)
            }
        }

        // Aggiorna annotazioni se cambia la lista o la foto
        let currentPOIIDs = Set(uiView.annotations.compactMap { ($0 as? MappedPOIAnnotation)?.poi.id })
        let newPOIIDs = Set(mappedPOIs.map { $0.id })
        if currentPOIIDs != newPOIIDs || mappedPOIs.contains(where: { poi in
            guard let annotation = uiView.annotations.first(where: { ($0 as? MappedPOIAnnotation)?.poi.id == poi.id }) as? MappedPOIAnnotation else { return true }
            return annotation.poi.photoPath != poi.photoPath
        }) {
            let toRemove = uiView.annotations.filter { !($0 is MKUserLocation) }
            uiView.removeAnnotations(toRemove)
            for poi in mappedPOIs {
                let annotation = MappedPOIAnnotation(poi: poi)
                uiView.addAnnotation(annotation)
            }
        }
    }

    private func centerCameraOnUser(_ mapView: MKMapView) {
        if let userLocation = mapView.userLocation.location {
            let camera = MKMapCamera(
                lookingAtCenter: userLocation.coordinate,
                fromDistance: 600,
                pitch: 75,
                heading: mapView.camera.heading
            )
            mapView.setCamera(camera, animated: true)
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
            if annotation is MKUserLocation { return nil }
            guard let poiAnnotation = annotation as? MappedPOIAnnotation else { return nil }

            if poiAnnotation.poi.isDiscovered, let photo = poiAnnotation.poi.photo {
                // POI scoperto: solo la foto come marker
                let identifier = "POIPhoto"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                if view == nil {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view?.canShowCallout = true
                    view?.centerOffset = CGPoint(x: 0, y: 0)
                } else {
                    view?.annotation = annotation
                }
                view?.image = photo.fixedOrientation().resizedToPin()
                return view
            } else {
                // POI non scoperto: marker default a tema con punto interrogativo
                let identifier = "POIMarker"
                var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if markerView == nil {
                    markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    markerView?.canShowCallout = true
                }
                markerView?.markerTintColor = .systemRed
                markerView?.glyphText = "?"
                markerView?.glyphImage = nil
                markerView?.annotation = annotation
                return markerView
            }
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

class MappedPOIAnnotation: NSObject, MKAnnotation {
    let poi: MappedPOI
    var coordinate: CLLocationCoordinate2D { poi.coordinate }
    var title: String? { poi.title }
    init(poi: MappedPOI) { self.poi = poi }
}

extension UIImage {
    // Ridimensiona per il pin
    func resizedToPin() -> UIImage {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? self
    }
    // Fissa l'orientamento (altrimenti rischi foto bianche)
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
