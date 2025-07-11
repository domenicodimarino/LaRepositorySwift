import SwiftUI
import MapKit

// Versione migliorata di CustomMapView
struct CustomMapView: UIViewRepresentable {
    @Binding var trackingState: TrackingState
    var mappedPOIs: [MappedPOI]
    @ObservedObject var avatarViewModel: AvatarViewModel
    var onPOISelected: ((MappedPOI) -> Void)? = nil
    
    let configuration: MKStandardMapConfiguration
    
    init(trackingState: Binding<TrackingState>,
         mappedPOIs: [MappedPOI],
         avatarViewModel: AvatarViewModel,
         onPOISelected: ((MappedPOI) -> Void)? = nil) {
        self._trackingState = trackingState
        self.mappedPOIs = mappedPOIs
        self.avatarViewModel = avatarViewModel
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
        
        // Disabilita l'icona utente standard
        mapView.showsUserLocation = false
        
        mapView.userTrackingMode = .none
        mapView.delegate = context.coordinator
        
        // Camera 3D iniziale
        let coordinate = CLLocationCoordinate2D(latitude: 40.7083, longitude: 14.7088)
        let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 600, pitch: 75, heading: 0)
        mapView.setCamera(camera, animated: false)
        
        // Aggiungi POI
        for poi in mappedPOIs {
            let annotation = MappedPOIAnnotation(poi: poi)
            mapView.addAnnotation(annotation)
        }
        
        // Aggiungi l'annotazione per l'utente
        let userAnnotation = CustomUserLocationAnnotation()
        mapView.addAnnotation(userAnnotation)
        context.coordinator.userAnnotation = userAnnotation
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Aggiorna la modalità di tracciamento
        switch trackingState {
        case .follow:
            if uiView.userTrackingMode != .follow {
                uiView.setUserTrackingMode(.follow, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    centerCameraOnUser(uiView, context: context)
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
        
        // Aggiorna la posizione dell'utente
        updateUserLocation(in: uiView, context: context)
        
        // AGGIUNTA: Controlla se l'avatar è stato aggiornato
                if context.coordinator.lastAvatarHash != avatarViewModel.avatar.hashValue {
                    context.coordinator.lastAvatarHash = avatarViewModel.avatar.hashValue
                    updateUserAvatarView(in: uiView, context: context)
                }
        
        // Gestione POI
        let currentAnnotations = uiView.annotations.compactMap { $0 as? MappedPOIAnnotation }
        let currentIDs = Set(currentAnnotations.map { $0.poi.id })
        let newIDs = Set(mappedPOIs.map { $0.id })
        
        // Aggiungi solo le nuove annotazioni
        let toAdd = mappedPOIs.filter { !currentIDs.contains($0.id) }
        for poi in toAdd {
            let annotation = MappedPOIAnnotation(poi: poi)
            uiView.addAnnotation(annotation)
        }
        
        // Rimuovi solo quelle eliminate
        let toRemove = currentAnnotations.filter { !newIDs.contains($0.poi.id) }
        uiView.removeAnnotations(toRemove)
        
        // Aggiorna annotazioni se cambiano
        for poi in mappedPOIs {
            if let annotation = currentAnnotations.first(where: { $0.poi.id == poi.id }) {
                let changedPhoto = annotation.poi.photoPath != poi.photoPath
                let changedState = annotation.poi.isDiscovered != poi.isDiscovered
                if changedPhoto || changedState {
                    uiView.removeAnnotation(annotation)
                    uiView.addAnnotation(MappedPOIAnnotation(poi: poi))
                }
            }
        }
    }
    //Aggiorna specificamente la vista dell'avatar
    private func updateUserAvatarView(in mapView: MKMapView, context: Context) {
            guard let userAnnotation = context.coordinator.userAnnotation,
                  let annotationView = mapView.view(for: userAnnotation) as? CustomUserAnnotationView else { return }
            
            // Forza l'aggiornamento dell'avatar
            annotationView.updateAvatar(with: avatarViewModel.avatar)
        }
    
    // Aggiorna la posizione dell'annotazione utente
    private func updateUserLocation(in mapView: MKMapView, context: Context) {
        guard let userAnnotation = context.coordinator.userAnnotation,
              let userLocation = mapView.userLocation.location else { return }
        
        // Aggiorna le coordinate dell'annotazione
        userAnnotation.coordinate = userLocation.coordinate
        
        // Ottieni la vista dell'annotazione
        if let annotationView = mapView.view(for: userAnnotation) as? CustomUserAnnotationView {
            // Aggiorna lo stato di movimento
            let speed = userLocation.speed
            let isMoving = speed > 0.5 // soglia di movimento
            annotationView.updateMovingState(isMoving)
            
            // Aggiorna la direzione
            if userLocation.course >= 0 {
                annotationView.updateHeading(userLocation.course)
            }
            
            // Aggiorna l'avatar se necessario
            annotationView.updateAvatar()
        }
    }
    
    private func centerCameraOnUser(_ mapView: MKMapView, context: Context) {
        if let userAnnotation = context.coordinator.userAnnotation {
            let camera = MKMapCamera(
                lookingAtCenter: userAnnotation.coordinate,
                fromDistance: 150,
                pitch: 65,
                heading: mapView.camera.heading
            )
            mapView.setCamera(camera, animated: true)
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        var userAnnotation: CustomUserLocationAnnotation?
        private var isRegionChangeFromUserInteraction = false
        var lastAvatarHash: Int = 0
        
        init(_ parent: CustomMapView) {
            self.parent = parent
            super.init()
        }
        
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
            // Gestione dell'annotazione posizione utente personalizzata
            if annotation is CustomUserLocationAnnotation {
                let reuseId = "userLocationView"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? CustomUserAnnotationView
                
                if view == nil {
                    view = CustomUserAnnotationView(
                        annotation: annotation,
                        reuseIdentifier: reuseId,
                        avatarViewModel: parent.avatarViewModel
                    )
                } else {
                    view?.annotation = annotation
                }
                
                return view
            }
            // Ignora l'annotazione standard della posizione utente
            else if annotation is MKUserLocation {
                return MKAnnotationView(annotation: annotation, reuseIdentifier: "hiddenUserLocation")
            }
            // Gestione POI
            else if let poiAnnotation = annotation as? MappedPOIAnnotation {
                if poiAnnotation.poi.isDiscovered, let photo = poiAnnotation.poi.photo {
                    let identifier = "POIPhoto"
                    var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                    if view == nil {
                        view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                        view?.canShowCallout = true
                    } else {
                        view?.annotation = annotation
                    }
                    view?.image = photo.fixedOrientation().resizedToPin()
                    return view
                } else {
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
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
