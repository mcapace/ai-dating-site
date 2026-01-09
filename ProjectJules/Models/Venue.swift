//
//  Venue.swift
//  ProjectJules
//
//  Venue and location models
//

import Foundation
import CoreLocation

struct Venue: Identifiable, Codable {
    let id: UUID
    let name: String
    var neighborhoodId: UUID?
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var venueType: String?
    var priceRange: String?
    var description: String?
    let createdAt: Date
    
    var location: CLLocation? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocation(latitude: lat, longitude: lon)
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct Neighborhood: Identifiable, Codable {
    let id: UUID
    let city: String
    let name: String
    var latitude: Double?
    var longitude: Double?
    let createdAt: Date
    
    var displayName: String {
        "\(name), \(city)"
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct UserNeighborhood: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let neighborhoodId: UUID
    let createdAt: Date
}

