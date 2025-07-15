import Foundation
import CoreLocation
import UIKit
import CryptoKit // Use CryptoKit instead of CommonCrypto

struct POI: Identifiable, Hashable {
    let street: String
    let streetNumber: String
    let city: String
    let province: String

    let diaryPlaceName: String
    var photoPath: String?
    var isDiscovered: Bool
    var discoveredTitle: String?
    var photo: UIImage?
    var discoveredDate: Date?
    var latitude: Double?
    var longitude: Double?
    let imageName: String
    
    // Use a computed property for a consistent ID
    var id: UUID {
        // Create a deterministic ID based on the place name and location
        let uniqueString = "\(diaryPlaceName)_\(latitude ?? 0)_\(longitude ?? 0)"
        
        // Create a SHA-256 hash using CryptoKit
        if let data = uniqueString.data(using: .utf8) {
            let hash = SHA256.hash(data: data)
            let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
            
            // Format first part as UUID
            let uuidFormat = String(hashString.prefix(32)).insertingSeparators()
            return UUID(uuidString: uuidFormat) ?? UUID()
        }
        
        // Fallback to random UUID if hashing fails
        return UUID()
    }
    
    var title: String {
        isDiscovered ? (discoveredTitle ?? "Punto di interesse") : "Punto di interesse"
    }
    
    var address: String {
        "\(street) \(streetNumber), \(city), \(province)"
    }
    
    var coordinate: CLLocationCoordinate2D? {
        if let lat = latitude, let lon = longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }

    init(
        street: String,
        streetNumber: String,
        city: String,
        province: String,
        diaryPlaceName: String,
        isDiscovered: Bool = false,
        discoveredTitle: String? = nil,
        photo: UIImage? = nil,
        photoPath: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        discoveredDate: Date? = nil,
        imageName: String
    ) {
        // Don't assign to id here since it's a computed property
        self.street = street
        self.streetNumber = streetNumber
        self.city = city
        self.province = province
        self.diaryPlaceName = diaryPlaceName
        self.photoPath = photoPath
        self.isDiscovered = isDiscovered
        self.discoveredTitle = discoveredTitle
        self.photo = photo
        self.latitude = latitude
        self.longitude = longitude
        self.discoveredDate = discoveredDate
        self.imageName = imageName
    }
}

// Helper extension to format a string as UUID
extension String {
    func insertingSeparators() -> String {
        var result = self
        if result.count >= 8 {
            result.insert("-", at: result.index(result.startIndex, offsetBy: 8))
        }
        if result.count >= 13 {
            result.insert("-", at: result.index(result.startIndex, offsetBy: 13))
        }
        if result.count >= 18 {
            result.insert("-", at: result.index(result.startIndex, offsetBy: 18))
        }
        if result.count >= 23 {
            result.insert("-", at: result.index(result.startIndex, offsetBy: 23))
        }
        return result
    }
}
