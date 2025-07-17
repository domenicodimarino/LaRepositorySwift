import SwiftUI
import MapKit

enum TransportMode {
    case walking
    case driving
    
    static func forSpeed(_ speed: Double) -> TransportMode {
        // Soglia in m/s: circa 25 km/h (6.9 m/s)
        return speed > 6.9 ? .driving : .walking
    }
}
struct UserMovementState {
    var isMoving: Bool = false
    var heading: Double = 0.0
    var cameraHeading: Double = 0.0
    var transportMode: TransportMode = .walking
    var speed: Double = 0.0

    func relativeDirection() -> AvatarDirection {
        let relativeAngle = (heading - cameraHeading + 360).truncatingRemainder(dividingBy: 360)
        switch relativeAngle {
        case 315...360, 0..<45: return .up
        case 45..<135: return .right
        case 135..<225: return .down
        case 225..<315: return .left
        default: return .down
        }
    }

    func currentAnimation() -> AvatarAnimation {
        isMoving ? .walk : .idle
    }
}

enum AvatarViewMode {
    case fullBody
    case headOnly
}

struct CustomMapView: UIViewRepresentable {
    @Binding var trackingState: TrackingState
    var mappedPOIs: [MappedPOI]
    @ObservedObject var avatarViewModel: AvatarViewModel
    var onPOISelected: ((MappedPOI?) -> Void)?
    var userLocation: CLLocation?

    private let configuration: MKMapConfiguration

    init(trackingState: Binding<TrackingState>,
         mappedPOIs: [MappedPOI],
         avatarViewModel: AvatarViewModel,
         onPOISelected: ((MappedPOI?) -> Void)? = nil,
         userLocation: CLLocation? = nil) {
        self._trackingState = trackingState
        self.mappedPOIs = mappedPOIs
        self.avatarViewModel = avatarViewModel
        self.onPOISelected = onPOISelected
        self.userLocation = userLocation

        var config = MKImageryMapConfiguration(elevationStyle: .realistic)
        configuration = config
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.preferredConfiguration = configuration
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        mapView.showsUserLocation = true
        mapView.showsUserTrackingButton = true

        if let userTrackingButton = mapView.subviews.first(where: { $0 is MKUserTrackingButton }) {
            userTrackingButton.frame = CGRect(x: mapView.frame.width - 55, y: 60, width: 44, height: 44)
        }

        mapView.delegate = context.coordinator

        // Posiziona la camera inizialmente su userLocation, se disponibile
        let initialCoordinate: CLLocationCoordinate2D
        if let userLocation = userLocation {
            initialCoordinate = userLocation.coordinate
        } else {
            initialCoordinate = CLLocationCoordinate2D(latitude: 40.7083, longitude: 14.7088)
        }
        let camera = MKMapCamera(lookingAtCenter: initialCoordinate, fromDistance: 300, pitch: 45, heading: 0)
        mapView.setCamera(camera, animated: false)

        for poi in mappedPOIs {
            let annotation = MappedPOIAnnotation(poi: poi)
            mapView.addAnnotation(annotation)
        }

        // Imposta il tracking mode all'avvio
        if trackingState == .follow {
            mapView.setUserTrackingMode(.follow, animated: false)
        }

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Sincronizza sempre la modalità di tracking tra stato SwiftUI e mappa
        switch trackingState {
        case .follow where mapView.userTrackingMode != .follow:
            mapView.setUserTrackingMode(.follow, animated: true)
        case .none where mapView.userTrackingMode != .none:
            mapView.setUserTrackingMode(.none, animated: true)
        default:
            break
        }

        // Aggiorna avatar se necessario
        if context.coordinator.lastAvatarHash != avatarViewModel.avatar.hashValue {
            context.coordinator.lastAvatarHash = avatarViewModel.avatar.hashValue
            context.coordinator.updateAvatarView(
                avatarViewModel: avatarViewModel
            )
        }

        updatePOIs(in: mapView)
    }

    private func updatePOIs(in mapView: MKMapView) {
        let currentAnnotations = mapView.annotations.compactMap { $0 as? MappedPOIAnnotation }
        let currentIDs = Set(currentAnnotations.map(\.poi.id))
        let newIDs = Set(mappedPOIs.map(\.id))

        mappedPOIs
            .filter { !currentIDs.contains($0.id) }
            .map(MappedPOIAnnotation.init)
            .forEach(mapView.addAnnotation)

        currentAnnotations
            .filter { !newIDs.contains($0.poi.id) }
            .forEach(mapView.removeAnnotation)

        for poi in mappedPOIs {
            if let annotation = currentAnnotations.first(where: { $0.poi.id == poi.id }) {
                let changedPhoto = annotation.poi.photoPath != poi.photoPath
                let changedState = annotation.poi.isDiscovered != poi.isDiscovered
                if changedPhoto || changedState {
                    mapView.removeAnnotation(annotation)
                    mapView.addAnnotation(MappedPOIAnnotation(poi: poi))
                }
            }
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        private var parent: CustomMapView
        private var avatarContainer: UIView?
        var lastAvatarHash: Int = 0
        var avatarHostingController: UIHostingController<AnyView>?

        private var userState = UserMovementState()
        private var cameraHeading: Double = 0.0

        private var currentAvatarViewMode: AvatarViewMode = .fullBody
        private let zoomThreshold: CLLocationDistance = 1000
        private var needsAvatarViewUpdate = false

        init(parent: CustomMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            // Aggiorna lo stato SwiftUI quando l'utente cambia modalità sulla mappa
            parent.trackingState = mode == .none ? .none : .follow
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MappedPOIAnnotation else { return }
            parent.onPOISelected?(annotation.poi)
        }

        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            parent.onPOISelected?(nil)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return userLocationView(for: annotation, in: mapView)
            }

            if let poiAnnotation = annotation as? MappedPOIAnnotation {
                if poiAnnotation.poi.isDiscovered, let photo = poiAnnotation.poi.photo {
                    return photoAnnotationView(for: poiAnnotation, photo: photo)
                } else {
                    return markerAnnotationView(for: poiAnnotation)
                }
            }

            return nil
        }

        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            guard let location = userLocation.location else { return }
            
            cameraHeading = mapView.camera.heading
            
            let speed = location.speed
            let isMoving = speed > 0.4
            let transportMode = TransportMode.forSpeed(speed)
            let heading = location.course >= 0 ? location.course : userState.heading
            
            if isMoving != userState.isMoving ||
               heading != userState.heading ||
               cameraHeading != userState.cameraHeading ||
               transportMode != userState.transportMode {
                
                userState = UserMovementState(
                    isMoving: isMoving,
                    heading: heading,
                    cameraHeading: cameraHeading,
                    transportMode: transportMode,
                    speed: speed
                )
                updateAvatarForMovement()
            }
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            let newCameraHeading = mapView.camera.heading
            if newCameraHeading != cameraHeading {
                cameraHeading = newCameraHeading
                userState.cameraHeading = cameraHeading
                updateAvatarForMovement()
            }

            let altitude = mapView.camera.altitude
            let newViewMode: AvatarViewMode = altitude > zoomThreshold ? .headOnly : .fullBody

            if newViewMode != currentAvatarViewMode {
                currentAvatarViewMode = newViewMode
                if !needsAvatarViewUpdate {
                    needsAvatarViewUpdate = true
                    DispatchQueue.main.async {
                        self.updateAvatarViewIfNeeded(in: mapView)
                        self.needsAvatarViewUpdate = false
                    }
                }
            }
        }

        private func updateAvatarViewIfNeeded(in mapView: MKMapView) {
            if let userAnnotationView = mapView.view(for: mapView.userLocation) {
                recreateAvatarView(in: userAnnotationView)
            }
        }

        private func userLocationView(for annotation: MKAnnotation, in mapView: MKMapView) -> MKAnnotationView {
            let reuseId = "userLocationView"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
                ?? MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)

            view.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            view.canShowCallout = false
            view.centerOffset = .zero
            view.zPriority = .init(rawValue: 3)

            recreateAvatarView(in: view)
            return view
        }

        func recreateAvatarView(in annotationView: MKAnnotationView) {
            annotationView.subviews.forEach { $0.removeFromSuperview() }
            
            // Dimensioni basate sulla modalità di visualizzazione
            let size: CGSize
            switch currentAvatarViewMode {
            case .fullBody:
                size = CGSize(width: 80, height: 80)
            case .headOnly:
                size = CGSize(width: 40, height: 40)
            }
            
            avatarContainer = UIView(frame: CGRect(origin: .zero, size: size))
            avatarContainer?.backgroundColor = .clear
            
            let avatarView: AnyView
            
            // Verifica se deve essere mostrata l'auto o l'avatar
            if userState.transportMode == .driving {
                // Mostra la macchina
                let carView = CarSpriteKitView(direction: userState.relativeDirection())
                    .withSize(width: size.width, height: size.height)
                
                avatarView = AnyView(carView)
            } else {
                // Mostra l'avatar normale
                switch currentAvatarViewMode {
                case .fullBody:
                    let fullView = AvatarSpriteKitView(
                        viewModel: parent.avatarViewModel,
                        initialAnimation: userState.currentAnimation(),
                        initialDirection: userState.relativeDirection()
                    )
                    .withSize(width: size.width, height: size.height)
                    
                    avatarView = AnyView(fullView)
                    
                case .headOnly:
                    let headOnlyView = AvatarHeadPreview(viewModel: parent.avatarViewModel, size: size)
                    avatarView = AnyView(headOnlyView)
                }
            }
            
            let hostingController = UIHostingController(rootView: avatarView)
            hostingController.view.backgroundColor = .clear
            hostingController.view.frame = avatarContainer?.bounds ?? CGRect(origin: .zero, size: size)
            hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            avatarContainer?.addSubview(hostingController.view)
            annotationView.addSubview(avatarContainer ?? UIView())
            avatarContainer?.center = CGPoint(x: annotationView.bounds.midX, y: annotationView.bounds.midY)
            
            avatarHostingController = hostingController
        }

        func updateAvatarView(avatarViewModel: AvatarViewModel) {
            if let hostingController = avatarHostingController {
                let avatarView: AnyView
                
                if userState.transportMode == .driving {
                    // Mostra la macchina
                    let carView = CarSpriteKitView(direction: userState.relativeDirection())
                        .withSize(width: 80, height: 80)
                    
                    avatarView = AnyView(carView)
                } else {
                    // Mostra l'avatar normale solo se in modalità fullBody
                    if case .fullBody = currentAvatarViewMode {
                        let fullView = AvatarSpriteKitView(
                            viewModel: avatarViewModel,
                            initialAnimation: userState.currentAnimation(),
                            initialDirection: userState.relativeDirection()
                        )
                        .withSize(width: 80, height: 80)
                        
                        avatarView = AnyView(fullView)
                    } else {
                        return // Non aggiornare in modalità headOnly
                    }
                }
                
                hostingController.rootView = avatarView
            }
        }

        private func updateAvatarForMovement() {
            if case .fullBody = currentAvatarViewMode {
                updateAvatarView(avatarViewModel: parent.avatarViewModel)
            }
        }

        private func photoAnnotationView(for annotation: MappedPOIAnnotation, photo: UIImage) -> MKAnnotationView {
            let identifier = "POIPhoto"
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            let containerSize = CGSize(width: 52, height: 52)
            let finalImage = UIGraphicsImageRenderer(size: containerSize).image { context in
                let glowPath = UIBezierPath(rect: CGRect(x: 1, y: 1, width: 50, height: 50))
                UIColor(white: 1.0, alpha: 0.8).setFill()
                glowPath.fill()

                let borderPath = UIBezierPath(rect: CGRect(x: 4, y: 4, width: 44, height: 44))
                UIColor.white.setFill()
                borderPath.fill()

                let resizedPhoto = photo.fixedOrientation().resizedToPin()
                let rect = CGRect(x: 6, y: 6, width: 40, height: 40)
                context.cgContext.addRect(rect)
                context.cgContext.clip()
                resizedPhoto.draw(in: rect)
            }

            view.image = finalImage
            view.layer.shadowColor = UIColor.white.cgColor
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowRadius = 8
            view.layer.shadowOpacity = 0.8
            view.zPriority = .init(rawValue: 2)
            view.displayPriority = .required
            view.centerOffset = CGPoint(x: 0, y: -10)

            return view
        }

        private func markerAnnotationView(for annotation: MappedPOIAnnotation) -> MKMarkerAnnotationView {
            let identifier = "POIMarker"
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.markerTintColor = .systemRed
            view.glyphText = "?"
            view.zPriority = .init(rawValue: 2)
            view.displayPriority = .required
            return view
        }
    }
}

extension UIImage {
    func resizedToPin() -> UIImage {
        let size = CGSize(width: 40, height: 40)
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

final class MappedPOIAnnotation: NSObject, MKAnnotation {
    let poi: MappedPOI
    var coordinate: CLLocationCoordinate2D { poi.coordinate }
    var title: String? { poi.title }

    init(poi: MappedPOI) {
        self.poi = poi
    }
}
