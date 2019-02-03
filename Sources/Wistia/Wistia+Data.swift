//
//  Wistia+Data.swift
//  Wistia
//
//  Created by Jake Young on 2/2/19.
//

import Foundation


// MARK: - Models
extension Wistia {
    
    // MARK: - Projects
    public struct Project: Codable {
        public let hashedId: String
        public let medias: [Media]
    }
    
    // MARK: - Medias
    public struct Media: Codable {
        
        public let hashed_id: String
        public let name: String
        public let type: String
        public let description: String
        public let section: String?
        public let duration: Double?
        
        public let thumbnail: Thumbnail
        
        public let assets: [Asset] = []
        
        public let embedCode: String?
        
        public struct Thumbnail: Codable {
            let url: URL
            let width: Int
            let height: Int
        }
        
        public struct Caption: Codable, Equatable {
            public let english_name: String
            public let native_name: String
            public let language: String
            public let text: String
        }
        
        public struct Asset: Codable, Equatable {
            
            public enum AssetKind: String, Codable {
                case original = "OriginalFile"
                case iphone = "IphoneVideoFile"
                case hls = "HlsVideoFile"
                case smallMP4 = "Mp4VideoFile"
                case standardDefinitionMP4 = "MdMp4VideoFile"
                case highDefinitionMP4 = "HdMp4VideoFile"
                case image = "StillImageFile"
                case storyboard = "StoryboardFile"
            }
            
            public let url: URL
            public let contentType: String
            public let type: AssetKind
            public let fileSize: Int
            public let height: Int
            public let width: Int
        }
    }
    
}


// MARK: - Routes & Endpoints
extension Wistia {
    
    /// Controls the common places of interacting with the Wistia Data API.
    ///
    /// - medias: list all the medias in your Wistia account
    /// - projects: list all the projects in your Wistia account
    /// - media: show the details for a media with an ID
    /// - mediaCaptions:  show the captions files for a media with an ID
    /// - project:  show the details for a project with an ID
    public enum DataRoute: RouteType {
        
        case medias
        case projects
        case media(id: String)
        case mediaCaptions(id: String)
        case project(id: String)
        
        public var path: String {
            switch self {
            case .medias:
                return "medias.json"
            case .media(let hashed_id):
                return "medias/\(hashed_id).json"
            case .mediaCaptions(let hashed_id):
                return "medias/\(hashed_id)/captions.json"
            case .projects:
                return "projects.json"
            case .project(let hashed_id):
                return "projects/\(hashed_id).json"
            }
        }
    }
    
}

internal func parse<T: Codable>(data: Data?, completionHandler: (T?, Error?) -> Void) {
    if let data = data {
        do {
            let decoder = JSONDecoder()
            let item = try decoder.decode(T.self, from: data)
            completionHandler(item, nil)
        } catch {
            completionHandler(nil, error)
        }
    } else {
        completionHandler(nil, nil)
    }
}

// MARK: - Project
extension Wistia {
    
    /// Gets the details for a project with a provided id.
    ///
    /// - Parameters:
    ///   - hashed_id: the hashed id needed to identify the project.
    ///   - completionHandler: returns an optional project or error. Error will be a network related error or a `WistiaError` depending on the issue.
    public func showProject(hashed_id: String, completionHandler: @escaping (Wistia.Project?, Error?) -> Void) {
        
        let route: Wistia.DataRoute = .project(id: hashed_id)
        let request = createRequest(route, queryParams: ["limit":"100"], httpBody: nil)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error)
                return completionHandler(nil, error)
            }
            
            parse(data: data, completionHandler: completionHandler)
            
        }
        task.resume()
    }
    
    /// Show the details for a given media.
    ///
    /// - Parameters:
    ///   - hashed_id: the hashed id needed to identify the media item.
    ///   - completionHandler: returns an optional project or error. Error will be a network related error or a `WistiaError` depending on the issue.
    public func showMedia(hashed_id: String, completionHandler: @escaping (Wistia.Media?, Error?) -> Void) {
        
        let route: Wistia.DataRoute = .media(id: hashed_id)
        let request = createRequest(route, queryParams: ["limit":"100"])
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error)
                return completionHandler(nil, error)
            }
            parse(data: data, completionHandler: completionHandler)
            
        }
        task.resume()
    }
    
    /// Lists all the captions entries for a given media.
    ///
    /// - Parameters:
    ///   - mediaId: the hashed id needed to identify the media item.
    ///   - completionHandler: returns an optional array of captions entities or error. Error will be a network related error or a `WistiaError` depending on the issue.
    public func showCaptionsForMedia(mediaId: String, completionHandler: @escaping ([Media.Caption]?, Error?) -> Void) {
        let route: Wistia.DataRoute = .mediaCaptions(id: mediaId)
        let request = createRequest(route, queryParams: ["limit":"100"])
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error)
                return completionHandler([], error)
            }
            
            parse(data: data, completionHandler: completionHandler)
        }
        task.resume()
    }
    
    /// Lists all the assets that match a given query. You often may just want the original video file.
    ///
    /// - Parameters:
    ///   - mediaId: the hashed id needed to identify the media item.
    ///   - assetType: the type of file that you want to filter by
    ///   - completionHandler: returns an optional array of Media Assets or error. Error will be a network related error or a `WistiaError` depending on the issue.
    public func showAssetsForMedia(mediaId: String, matchingAssetType assetType: String? = nil, completionHandler: @escaping ([Media.Asset]?, Error?) -> Void) {
        
        showMedia(hashed_id: mediaId) { (media, error) in
            
            var filtered: [Media.Asset]?
            if assetType == nil {
                filtered = media?.assets
            } else {
                filtered = media?.assetsMatching(assetType: assetType!)
            }
            
            completionHandler(filtered, error)
        }
        
    }
    
}

extension Wistia.Media {
    /// Provides any assets matching a given asset type.
    ///
    /// - Parameter assetType: enum from data API
    /// - Returns: an array of media assets
    func assetsMatching(assetType: String) -> [Asset] {
        return assets.filter { $0.type.rawValue.localizedCaseInsensitiveContains(assetType) }
    }
    /// Provides any assets matching a given asset type.
    ///
    /// - Parameter assetType: enum from data API
    /// - Returns: an array of media assets
    func assetsMatching(assetType: Asset.AssetKind) -> [Asset] {
        return assets.filter { $0.type == assetType }
    }
}

extension Wistia.Media.Asset {
    
    /// Formatted file size string
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSize))
    }
}
