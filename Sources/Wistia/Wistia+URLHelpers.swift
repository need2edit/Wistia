//
//  Wistia+URLHelpers.swift
//  Wistia
//
//  Created by Jake Young on 3/27/19.
//

import Foundation

extension String.StringInterpolation {
    
    public mutating func appendInterpolation(admin value: Wistia.Media) {
        appendLiteral("https://acpdecisions.wistia.com/medias/\(value.hashed_id)")
    }
    
    public mutating func appendInterpolation(thumbnail value: Wistia.Media) {
        appendLiteral(value.thumbnail.url.absoluteString)
    }
    
    public mutating func appendInterpolation(url value: Wistia.Media, ofKind kind: Wistia.Media.Asset.AssetKind) {
        guard let assets = value.assets else { return }
        let filtered = assets.filter { $0.type == kind }
        for asset in filtered {
            appendLiteral(asset.url)
        }
    }
    
}
