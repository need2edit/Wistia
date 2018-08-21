import Foundation

/// Wistia.
/// Class for managing common Wistia Data API Tasks.
public class Wistia {
    
    // MARK: Properties
    let baseURL = "https://api.wistia.com/v1/"
    let api_password: String
    let session = URLSession.shared
    
    init(api_password: String) {
        self.api_password = api_password
    }
    
}

// MARK: - Error Handling
extension Wistia {
    
    enum WistiaError: Error, CustomStringConvertible {
        case invalidAPIKey
        case noData
        var description: String {
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
    struct Project: Codable {
        let hashed_id: String
        let medias: [Media]
    }
    
    // MARK: - Medias
    struct Media: Codable {
        
        let hashed_id: String
        let name: String
        let type: String
        let description: String
        let section: String?
        
        let thumbnail: Thumbnail
        
        let assets: [Asset]
        
        struct Thumbnail: Codable {
            let url: URL
            let width: Int
            let height: Int
        }
        
        struct Caption: Codable {
            let english_name: String
            let native_name: String
            let language: String
            let text: String
        }
        
        struct Asset: Codable {
            let url: URL
            let contentType: String
            let type: String
            let fileSize: Int
            let height: Int
            let width: Int
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
    enum Route {
        
        case medias
        case projects
        case media(id: String)
        case mediaCaptions(id: String)
        case project(id: String)
        
        var path: String {
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

func parse<T: Codable>(data: Data?, completionHandler: (T?, Error?) -> Void) {
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
    func showProject(hashed_id: String, completionHandler: @escaping (Wistia.Project?, Error?) -> Void) {
        
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
    func showMedia(hashed_id: String, completionHandler: @escaping (Wistia.Media?, Error?) -> Void) {
        
        let route: Wistia.Route = .project(id: hashed_id)
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
    
}
