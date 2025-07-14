import SwiftUI
import MapKit

struct UserMovementState {
    var isMoving: Bool = false
    var heading: Double = 0.0
}

// Versione migliorata e semplificata di CustomMapView
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
        
        // Mostra la posizione dell'utente
        mapView.showsUserLocation = true
        
        // Usa il pulsante nativo di MapKit
        mapView.showsUserTrackingButton = true
        
        // Posiziona il pulsante in alto a destra (opzionale)
        if let userTrackingButton = mapView.subviews.first(where: { $0 is MKUserTrackingButton }) {
            userTrackingButton.frame = CGRect(x: mapView.frame.width - 55, y: 60, width: 44, height: 44)
        }
        
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
        // Sincronizza lo stato di tracking con la mappa
        switch trackingState {
                case .follow:
                    if uiView.userTrackingMode == .none {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            
                            
                            
                            if let userAnnotationView = uiView.view(for: uiView.userLocation) {
                                // Rimuovi e ricrea l'avatar completamente
                                context.coordinator.recreateAvatarView(in: userAnnotationView)
                            }
                        }
                    }
                case .none:
                    if uiView.userTrackingMode != .none {
                        uiView.setUserTrackingMode(.none, animated: true)
                    }
                }
        
        // Controllo del movimento dell'utente per l'animazione
        if let userLocation = uiView.userLocation.location {
            let speed = userLocation.speed
            let isMoving = speed > 0.4
            
            var heading = userState.heading
            if userLocation.course >= 0 {
                heading = userLocation.course
            }
            
            if isMoving != userState.isMoving || abs(heading - userState.heading) > 10 {
                DispatchQueue.main.async {
                    self.userState.isMoving = isMoving
                    self.userState.heading = heading
                    self.updateUserAnimation(in: uiView, context: context)
                }
            }
        }
        
        // Aggiorna l'avatar se è cambiato
        if context.coordinator.lastAvatarHash != avatarViewModel.avatar.hashValue {
            context.coordinator.lastAvatarHash = avatarViewModel.avatar.hashValue
            updateUserAvatarView(in: uiView, context: context)
        }
        
        // Gestione POI (il codice per aggiornare le annotazioni è corretto, lo lascio invariato)
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
    
    // FUNZIONE: aggiorna l'animazione dell'avatar
    private func updateUserAnimation(in mapView: MKMapView, context: Context) {
        if let hostingController = context.coordinator.avatarHostingController {
            let direction = directionFromHeading(userState.heading)
            let animation = userState.isMoving ? AvatarAnimation.walk : AvatarAnimation.idle
            
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
        case 315...360, 0..<45: return .up
        case 45..<135: return .right
        case 135..<225: return .down
        case 225..<315: return .left
        default: return .down
        }
    }
    
    private func updateUserAvatarView(in mapView: MKMapView, context: Context) {
        if let hostingController = context.coordinator.avatarHostingController {
            let direction = directionFromHeading(userState.heading)
            let animation = userState.isMoving ? AvatarAnimation.walk : AvatarAnimation.idle
            
            // Aggiorna la rootView mantenendo le stesse dimensioni
            hostingController.rootView = AvatarSpriteKitView(
                viewModel: avatarViewModel,
                initialAnimation: animation,
                initialDirection: direction
            )
            .withSize(width: 128, height: 128)
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        var lastAvatarHash: Int = 0
        var avatarHostingController: UIHostingController<AvatarSpriteKitView>?
        
        init(_ parent: CustomMapView) {
            self.parent = parent
            super.init()
        }
        
        // Sincronizza lo stato di tracking quando cambia nella mappa
        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            DispatchQueue.main.async {
                self.parent.trackingState = mode == .none ? .none : .follow
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MappedPOIAnnotation {
                self.parent.onPOISelected?(annotation.poi)
            }
        }
        
        func recreateAvatarView(in annotationView: MKAnnotationView) {
            // Rimuovi tutte le subviews esistenti
                for subview in annotationView.subviews {
                    subview.removeFromSuperview()
                }
                
                // Usa dimensioni più piccole per la mappa
                let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 128, height: 128))
                containerView.backgroundColor = .clear
                
                // Usa l'avatar con scala 0.5 (metà dimensione)
                let avatarView = AvatarSpriteKitView(
                    viewModel: self.parent.avatarViewModel,
                    initialAnimation: self.parent.userState.isMoving ? .walk : .idle,
                    initialDirection: self.parent.directionFromHeading(self.parent.userState.heading)
                )
                .withSize(width: 128, height: 128)
            
                    
                    // Configura il nuovo hosting controller
                    let hostingController = UIHostingController(rootView: avatarView)
                    hostingController.view.backgroundColor = .clear
                    hostingController.view.frame = CGRect(x: 0, y: 0, width: 128, height: 128)
                    hostingController.view.autoresizingMask = []
                    hostingController.view.clipsToBounds = false
                    
                    // Aggiungi le views
                    containerView.addSubview(hostingController.view)
                    annotationView.addSubview(containerView)
                    
                    // Centra correttamente
                    containerView.center = CGPoint(x: annotationView.frame.width / 2, y: annotationView.frame.height / 2)
                    
            self.avatarHostingController = hostingController
            
                    // Debug
                    print("🔄 Avatar ricreato con dimensioni: \(hostingController.view.frame.size)")
                }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Personalizza l'indicatore utente standard
            if annotation is MKUserLocation {
                let reuseId = "userLocationView"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
                
                if view == nil {
                    // IMPORTANTE: imposta una dimensione fissa per l'annotation view
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                    view?.frame = CGRect(x: 0, y: 0, width: 128, height: 128)
                    
                    // Inizializza con il metodo comune
                    recreateAvatarView(in: view!)
                } else {
                    view?.annotation = annotation
                    
                    // Forziamo una dimensione anche quando viene riciclata
                    view?.frame = CGRect(x: 0, y: 0, width: 128, height: 128)
                    
                    // Ricrea anche durante il riciclo
                    recreateAvatarView(in: view!)
                }
                
                // Disabilita il comportamento standard della mappa
                view?.canShowCallout = false
                
                // Questo è importante per mantenere l'avatar centrato sulla posizione
                view?.centerOffset = CGPoint(x: 0, y: 0)
                
                // NUOVO: Imposta zPriority minima per l'avatar utente
                view?.zPriority = .min
                
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
                    
                    // NUOVO: Imposta zPriority massima per i POI
                    view?.zPriority = .max
                    view?.displayPriority = .required
                    
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
                    
                    // NUOVO: Imposta zPriority massima per i POI
                    markerView?.zPriority = .max
                    markerView?.displayPriority = .required
                    
                    return markerView
                }
            }
            
            return nil
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            if let location = userLocation.location {
                let speed = location.speed
                let isMoving = speed > 0.4
                
                if isMoving || self.parent.userState.isMoving != isMoving {
                    DispatchQueue.main.async {
                        // Aggiorna lo stato
                        self.parent.userState.isMoving = isMoving
                        
                        if location.course >= 0 {
                            self.parent.userState.heading = location.course
                        }
                        
                        if let hostingController = self.avatarHostingController {
                            let direction = self.parent.directionFromHeading(self.parent.userState.heading)
                            let animation = isMoving ? AvatarAnimation.walk : AvatarAnimation.idle
                            
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
