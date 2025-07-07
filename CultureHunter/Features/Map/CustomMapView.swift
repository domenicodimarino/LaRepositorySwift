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
        
        // Imposta la posizione iniziale su Napoli solo se non viene richiesta la centratura sulla posizione utente
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
        
        // Centra subito sulla posizione utente all'avvio, se possibile
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            mapView.userTrackingMode = .follow
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Tracking automatico: se trackingState == .follow, segui sempre l'utente
        if trackingState == .follow {
            if uiView.userTrackingMode != .follow {
                uiView.userTrackingMode = .follow
            }
        } else {
            if uiView.userTrackingMode != .none {
                uiView.userTrackingMode = .none
            }
        }
        
        // Centra una tantum se richiesto dal bottone o da onAppear della view principale
        if shouldCenterUser {
            uiView.userTrackingMode = .follow
            DispatchQueue.main.async {
                self.shouldCenterUser = false
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
        
        // Quando l'utente muove la mappa manualmente, disattiva il tracking automatico
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            if mapView.userTrackingMode != .none {
                mapView.userTrackingMode = .none
                DispatchQueue.main.async {
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
    }
}
