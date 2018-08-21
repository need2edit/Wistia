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
