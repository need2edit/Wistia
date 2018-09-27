import Foundation

/// Wistia.
/// Class for managing common Wistia Data API Tasks.
public class Wistia {
    
    // MARK: Properties
    public let baseURL = "https://api.wistia.com/v1/"
    private let api_password: String
    private let session = URLSession.shared
    
    public init(api_password: String) {
        self.api_password = api_password
    }
    
}

// MARK: - Error Handling
extension Wistia {
    
    public enum WistiaError: Error, CustomStringConvertible {
        case invalidAPIKey
        case noData
        public var description: String {
            switch self {
                
            case .invalidAPIKey:
                return "An invalid API key has been provided."
            case .noData:
                return "No data was provided from the Wistia API."
            }
        }
    }
    
}

// MARK: - Models
extension Wistia {
    
    // MARK: - Projects
    public struct Project: Codable {
        public let hashed_id: String
        public let medias: [Media]
    }
    
    // MARK: - Medias
    public struct Media: Codable {
        
        public let hashed_id: String
        public let name: String
        public let type: String
        public let description: String
        public let section: String?
        
        public let thumbnail: Thumbnail
        
        public let assets: [Asset]
        
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
            public let url: URL
            public let contentType: String
            public let type: String
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
    public enum Route {
        
        case medias
        case projects
        case media(id: String)
        case mediaCaptions(id: String)
        case project(id: String)
        
        public var path: String {
            switch self {
            case .medias:
                return "medias"
            case .media(let hashed_id):
                return "medias/\(hashed_id).json"
            case .mediaCaptions(let hashed_id):
                return "medias/\(hashed_id)/captions.json"
            case .projects:
                return "projects"
            case .project(let hashed_id):
                return "projects/\(hashed_id).json"
            }
        }
    }
    
}

fileprivate func parse<T: Codable>(data: Data?, completionHandler: (T?, Error?) -> Void) {
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

// MARK: - Networking
extension Wistia {
    
    private func createRequest(route: Route, httpMethod: HTTPMethod, queryParams: [String: String], httpBody: Data?) -> URLRequest {
        let urlString = baseURL + route.path + "?api_password=\(api_password)"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBody
        return request
    }
    
    
    /// Gets the details for a project with a provided id.
    ///
    /// - Parameters:
    ///   - hashed_id: the hashed id needed to identify the project.
    ///   - completionHandler: returns an optional project or error. Error will be a network related error or a `WistiaError` depending on the issue.
    public func showProject(hashed_id: String, completionHandler: @escaping (Wistia.Project?, Error?) -> Void) {
        
        let route: Wistia.Route = .media(id: hashed_id)
        let request = createRequest(route: route, httpMethod: .get, queryParams: ["limit":"100"], httpBody: nil)
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
        
        let route: Wistia.Route = .project(id: hashed_id)
        let request = createRequest(route: route, httpMethod: .get, queryParams: ["limit":"100"], httpBody: nil)
        let task = session.dataTask(with: request) { (data, response, error) in
            
//            print((response as! HTTPURLResponse).statusCode)
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
        let route: Wistia.Route = .mediaCaptions(id: mediaId)
        let request = createRequest(route: route, httpMethod: .get, queryParams: ["limit":"100"], httpBody: nil)
        let task = session.dataTask(with: request) { (data, response, error) in
            
//            print((response as! HTTPURLResponse).statusCode)
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
    public func showAssetsForMedia(mediaId: String, matchingAssetType assetType: String, completionHandler: @escaping ([Media.Asset]?, Error?) -> Void) {
        
        showMedia(hashed_id: mediaId) { (media, error) in
            let assets = media?.assets.filter { $0.type.localizedCaseInsensitiveContains(assetType) }
            completionHandler(assets, error)
        }
        
    }
    
}
