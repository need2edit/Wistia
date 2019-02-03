import Foundation

/// Wistia.
/// Class for managing common Wistia Data API Tasks.
public class Wistia {
    
    // MARK: Properties
    public let baseURL = "https://api.wistia.com/v1/"
    internal let api_password: String
    internal let session = URLSession.shared
    
    public init(api_password: String) {
        self.api_password = api_password
    }
    
    public var debugMode: DebugMode = .off
    
    public enum DebugMode {
        case off
        case normal
        case verbose
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

extension Wistia {
    
    
    /// Creates a request using a generic route type and adds the API password to it.
    ///
    /// - Parameters:
    ///   - route: the route to create the request with (`RouteType` provides path information)
    ///   - httpMethod: standard `HTTPMethod`
    ///   - queryParams: optional query paramters
    ///   - httpBody: optional data for HTTP body
    /// - Returns: a fully formed `URLRequest` ready for the Wistia API
    func createRequest(_ route: RouteType, httpMethod: HTTPMethod = .get, queryParams: [String: String] = [:], httpBody: Data? = nil) -> URLRequest {
        
        // handle this with an adapter in another framework
        var newQueryParams = queryParams
        newQueryParams["api_password"] = api_password
        
        let urlString = baseURL + route.path
        
        var url = URL(string: urlString)!
        url = url.appendingQueryParameters(newQueryParams)
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBody
        
        switch self.debugMode {
        case .off:
            break
        case .normal:
            print(request.description)
        case .verbose:
            print(route)
            print(request.url ?? "No URL")
            print(request.debugDescription)
        }
        
        return request
    }
}
