//
//  Venue.swift
//  ProjectJules
//
//  Core Data Models: Venues & Locations
//

import Foundation
import CoreLocation

// MARK: - City
struct City: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var code: String  // e.g., "nyc"
    var isActive: Bool
    var launchedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case code
        case isActive = "is_active"
        case launchedAt = "launched_at"
    }
}

// MARK: - Neighborhood
struct Neighborhood: Codable, Identifiable, Equatable {
    let id: String
    let cityId: String
    var name: String
    var displayName: String
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case cityId = "city_id"
        case name
        case displayName = "display_name"
        case latitude
        case longitude
    }
}

// MARK: - Venue
struct Venue: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var address: String
    let neighborhoodId: String
    var latitude: Double
    var longitude: Double
    var venueType: VenueType
    var vibe: VenueVibe
    var priceRange: PriceRange
    var noiseLevel: NoiseLevel
    var goodForConvo: Bool
    var photoUrl: String?
    var isPartner: Bool
    var isActive: Bool
    var createdAt: Date

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var priceDisplayString: String {
        priceRange.rawValue
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case neighborhoodId = "neighborhood_id"
        case latitude
        case longitude
        case venueType = "venue_type"
        case vibe
        case priceRange = "price_range"
        case noiseLevel = "noise_level"
        case goodForConvo = "good_for_convo"
        case photoUrl = "photo_url"
        case isPartner = "is_partner"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

enum VenueType: String, Codable, CaseIterable {
    case bar
    case restaurant
    case coffee
    case activity

    var displayName: String {
        switch self {
        case .bar: return "Bar"
        case .restaurant: return "Restaurant"
        case .coffee: return "Coffee Shop"
        case .activity: return "Activity"
        }
    }

    var icon: String {
        switch self {
        case .bar: return "wineglass"
        case .restaurant: return "fork.knife"
        case .coffee: return "cup.and.saucer"
        case .activity: return "figure.walk"
        }
    }
}

enum VenueVibe: String, Codable, CaseIterable {
    case intimate
    case lively
    case casual
    case upscale

    var displayName: String {
        switch self {
        case .intimate: return "Intimate"
        case .lively: return "Lively"
        case .casual: return "Casual"
        case .upscale: return "Upscale"
        }
    }

    var description: String {
        switch self {
        case .intimate: return "Cozy and quiet, perfect for getting to know someone"
        case .lively: return "Energetic atmosphere with good buzz"
        case .casual: return "Relaxed and low-pressure"
        case .upscale: return "Sophisticated setting for a special night"
        }
    }
}

enum PriceRange: String, Codable, CaseIterable {
    case budget = "$"
    case moderate = "$$"
    case upscale = "$$$"

    var displayName: String {
        switch self {
        case .budget: return "Budget-friendly"
        case .moderate: return "Moderate"
        case .upscale: return "Splurge-worthy"
        }
    }
}

enum NoiseLevel: String, Codable, CaseIterable {
    case quiet
    case moderate
    case loud

    var displayName: String {
        switch self {
        case .quiet: return "Quiet"
        case .moderate: return "Moderate"
        case .loud: return "Lively"
        }
    }

    var icon: String {
        switch self {
        case .quiet: return "speaker.wave.1"
        case .moderate: return "speaker.wave.2"
        case .loud: return "speaker.wave.3"
        }
    }
}

// MARK: - Venue with Neighborhood (For display)
struct VenueWithLocation {
    let venue: Venue
    let neighborhood: Neighborhood

    var fullAddress: String {
        "\(venue.address), \(neighborhood.displayName)"
    }

    var julesDescription: String {
        var parts: [String] = []

        switch venue.vibe {
        case .intimate:
            parts.append("Cozy spot")
        case .lively:
            parts.append("Great energy")
        case .casual:
            parts.append("Relaxed vibe")
        case .upscale:
            parts.append("Sophisticated choice")
        }

        if venue.goodForConvo {
            parts.append("great for conversation")
        }

        switch venue.noiseLevel {
        case .quiet:
            parts.append("nice and quiet")
        case .moderate:
            parts.append("good background buzz")
        case .loud:
            break // Don't mention if loud
        }

        return parts.joined(separator: ", ") + "."
    }
}

// MARK: - NYC Neighborhoods (Seed Data)
struct NYCNeighborhoods {
    static let all: [(name: String, displayName: String, lat: Double, lng: Double)] = [
        ("downtown_manhattan", "Downtown / West Village", 40.7336, -74.0027),
        ("east_village_les", "East Village / LES", 40.7265, -73.9815),
        ("soho_tribeca", "SoHo / Tribeca", 40.7233, -74.0030),
        ("midtown", "Midtown", 40.7549, -73.9840),
        ("ues", "Upper East Side", 40.7736, -73.9566),
        ("uws", "Upper West Side", 40.7870, -73.9754),
        ("williamsburg", "Williamsburg", 40.7081, -73.9571),
        ("greenpoint", "Greenpoint", 40.7282, -73.9485),
        ("park_slope", "Park Slope", 40.6710, -73.9814),
        ("prospect_heights", "Prospect Heights", 40.6775, -73.9692),
        ("cobble_hill_carroll", "Cobble Hill / Carroll Gardens", 40.6860, -73.9969),
        ("dumbo_brooklyn_heights", "DUMBO / Brooklyn Heights", 40.6966, -73.9897),
        ("lic_astoria", "LIC / Astoria", 40.7441, -73.9226),
    ]
}

