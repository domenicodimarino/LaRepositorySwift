import SwiftUI
import MapKit

struct UserMovementState {
    var isMoving: Bool = false
    var heading: Double = 0.0
}

// Versione migliorata di CustomMapView
struct CustomMapView: UIViewRepresentable {
    @Binding var trackingState: TrackingState
    var mappedPOIs: [MappedPOI]
    @ObservedObject var avatarViewModel: AvatarViewModel
    var onPOISelected: ((MappedPOI) -> Void)? = nil
    
    // Stato del movimento dell'utente
    @State private var userState = UserMovementState()
    
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
        
        // IMPORTANTE: Usa l'animazione fluida integrata di MapKit
        mapView.showsUserLocation = true
        
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
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Aggiorna la modalità di tracciamento
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
        // Controllo del movimento dell'utente
        if let userLocation = uiView.userLocation.location {
            // Determina se l'utente è in movimento
            let speed = userLocation.speed
            let isMoving = speed > 0.25 // soglia di movimento (in m/s)
            
            // Aggiorna l'heading se disponibile
            var heading = userState.heading
            if userLocation.course >= 0 {
                heading = userLocation.course
            }
            
            // Se lo stato è cambiato, aggiorna l'animazione
            if isMoving != userState.isMoving || abs(heading - userState.heading) > 10 {
                DispatchQueue.main.async {
                    self.userState.isMoving = isMoving
                    self.userState.heading = heading
                    
                    // Aggiorna l'avatar con il nuovo stato di movimento
                    self.updateUserAnimation(in: uiView, context: context)
                }
            }
        }
        
        // Aggiorna l'avatar se è cambiato
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
    
    // NUOVA FUNZIONE: aggiorna l'animazione dell'avatar
    private func updateUserAnimation(in mapView: MKMapView, context: Context) {
        // Non fare unwrap di userLocation che non è opzionale
        let userLocation = mapView.userLocation
        
        if let hostingController = context.coordinator.avatarHostingController {
            // Determina la direzione in base all'heading
            let direction = directionFromHeading(userState.heading)
            
            // Aggiorna l'animazione dell'avatar - CORREZIONE: specificare esplicitamente AvatarAnimation
            let animation: AvatarAnimation = userState.isMoving ? AvatarAnimation.walk : AvatarAnimation.idle
            
            // Aggiorna la vista dell'avatar
            let avatarView = AvatarSpriteKitView(
                viewModel: avatarViewModel,
                initialAnimation: animation,
                initialDirection: direction
            )
            .withSize(width: 128, height: 128)
            
            hostingController.rootView = avatarView
        }
    }
    
    // Funzione per convertire l'heading in direzione
    private func directionFromHeading(_ heading: Double) -> AvatarDirection {
        let normalizedHeading = heading < 0 ? heading + 360 : heading
        
        switch normalizedHeading {
        case 315...360, 0..<45:
            return .up
        case 45..<135:
            return .right
        case 135..<225:
            return .down
        case 225..<315:
            return .left
        default:
            return .down
        }
    }
    
    // Aggiorna specificamente la vista dell'avatar
    private func updateUserAvatarView(in mapView: MKMapView, context: Context) {
        // Rimuovi unwrapping non necessario
        let userLocation = mapView.userLocation
        
        if let hostingController = context.coordinator.avatarHostingController {
            let direction = directionFromHeading(userState.heading)
            let animation: AvatarAnimation = userState.isMoving ? AvatarAnimation.walk : AvatarAnimation.idle
            
            let avatarView = AvatarSpriteKitView(
                viewModel: avatarViewModel,
                initialAnimation: animation,
                initialDirection: direction
            )
            .withSize(width: 128, height: 128)
            
            hostingController.rootView = avatarView
        }
    }
    
    private func centerCameraOnUser(_ mapView: MKMapView) {
        if let userLocation = mapView.userLocation.location {
            let camera = MKMapCamera(
                lookingAtCenter: userLocation.coordinate,
                fromDistance: 150,
                pitch: 65,
                heading: mapView.camera.heading
            )
            mapView.setCamera(camera, animated: true)
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        private var isRegionChangeFromUserInteraction = false
        var lastAvatarHash: Int = 0
        var avatarHostingController: UIHostingController<AvatarSpriteKitView>?
        
        init(_ parent: CustomMapView) {
            self.parent = parent
            super.init()
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            isRegionChangeFromUserInteraction = mapViewIsUserInteraction(mapView)
            if self.parent.trackingState == .follow && isRegionChangeFromUserInteraction {
                mapView.setUserTrackingMode(.none, animated: true)
                DispatchQueue.main.async {
                    self.parent.trackingState = .none
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MappedPOIAnnotation {
                self.parent.onPOISelected?(annotation.poi)
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Personalizza l'indicatore utente standard
            if annotation is MKUserLocation {
                let reuseId = "userLocationView"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
                
                if view == nil {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                    view?.frame = CGRect(x: 0, y: 0, width: 128, height: 128)
                    
                    // Crea una vista con l'avatar personalizzato
                    let avatarView = AvatarSpriteKitView(
                        viewModel: self.parent.avatarViewModel,
                        initialAnimation: .idle
                    )
                    .withSize(width: 128, height: 128)
                    
                    let hostingController = UIHostingController(rootView: avatarView)
                    hostingController.view.backgroundColor = .clear
                    
                    // IMPORTANTE: Dimensioni corrispondenti all'annotazione
                    hostingController.view.frame = CGRect(x: -32, y: -64, width: 128, height: 128)
                    
                    view?.addSubview(hostingController.view)
                    
                    // Nascondi l'indicatore blu standard
                    view?.canShowCallout = false
                    
                    // IMPORTANTE: Offset verticale per posizionare correttamente l'avatar
                    view?.centerOffset = CGPoint(x: 0, y: 32)
                    
                    // Salva il riferimento all'hosting controller
                    self.avatarHostingController = hostingController
                } else {
                    // Aggiorna l'annotazione
                    view?.annotation = annotation
                    
                }
                
                return view
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
        
        // Modifica 2: In didUpdate, gestisci meglio il caso di course negativo
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            if let location = userLocation.location {
                // Determina se l'utente è in movimento
                let speed = location.speed
                let isMoving = speed > 0.25
                
                print("🚶 Speed: \(speed) m/s, Course: \(location.course), Moving: \(isMoving)")
                
                // Forza sempre l'aggiornamento dell'UI se l'utente è in movimento
                if isMoving || self.parent.userState.isMoving != isMoving {
                    DispatchQueue.main.async {
                        // Aggiorna lo stato
                        self.parent.userState.isMoving = isMoving
                        
                        // Aggiorna la direzione solo se è disponibile un corso valido
                        if location.course >= 0 {
                            self.parent.userState.heading = location.course
                        }
                        
                        // Forza l'aggiornamento dell'animazione
                        if let hostingController = self.avatarHostingController {
                            let direction = self.parent.directionFromHeading(self.parent.userState.heading)
                            
                            // FORZA l'animazione walk se si sta muovendo
                            let animation = isMoving ? AvatarAnimation.walk : AvatarAnimation.idle
                            print("🎬 Impostando animazione: \(animation), direzione: \(direction)")
                            
                            let avatarView = AvatarSpriteKitView(
                                viewModel: self.parent.avatarViewModel,
                                initialAnimation: animation,
                                initialDirection: direction
                            )
                            .withSize(width: 128, height: 128)
                            
                            hostingController.rootView = avatarView
                        }
                    }
                }
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
