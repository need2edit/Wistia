//
//  WistiaStats.swift
//  Wistia
//
//  Created by Jake Young on 1/4/19.
//

import Foundation

extension Wistia {
    
    public enum StatsRoute: RouteType {
        
        /// GET https://api.wistia.com/v1/stats/account.json
        case account
        
        /// GET https://api.wistia.com/v1/stats/projects/[project-id].json
        case project(id: String)
        
        /// GET https://api.wistia.com/v1/stats/medias/[media-id].json
        case media(id: String)
        
        /// GET https://api.wistia.com/v1/stats/medias/[media-id]/engagement.json
        case mediaEngagement(id: String)
        
        /// GET https://api.wistia.com/v1/stats/visitors.json
        case visitors
        
        /// GET https://api.wistia.com/v1/stats/visitors/[visitor-key].json
        case visitor(key: String)
        
        /// GET https://api.wistia.com/v1/stats/events.json
        case events
        
        /// GET https://api.wistia.com/v1/stats/events/[event-key].json
        case event(key: String)
        
        /// GET https://api.wistia.com/v1/stats/events/[event-key]/iframe.html?public_token=[public_token]
        case heatmap(eventKey: String, publicToken: String)
        
        public var path: String {
            switch self {
            case .visitors:
                return "stats/visitors.json"
            case .media(let id):
                return "stats/medias/\(id).json"
            case .events:
                return "stats/events.json"
            case .account:
                return "stats/account.json"
            case .project(let id):
                return "stats/projects/\(id).json"
            case .mediaEngagement(let key):
                return "stats/medias/\(key)/engagement.json"
            case .visitor(let key):
                return "stats/visitors/\(key).json"
            case .event(let key):
                return "stats/events/\(key).json"
            case .heatmap(let eventKey, let publicToken):
                return "https://api.wistia.com/v1/stats/events/\(eventKey)/iframe.html?public_token=\(publicToken)"
            }
        }
    }
    
    // MARK: - Stats API
    public class Stats { }
    
}

extension Wistia.Stats {
    
    public struct Visitor: Codable {
        
        public let visitor_key: String
        public let load_count: Int
        public let play_count: Int
        
    }
    
    public struct VisitorIdentity: Codable {
        
        public let name: String?
        public let email: String?
        public let org: [String: String]?
        
    }
    
    public struct UserAgentDetails: Codable {
        public let browser: String
        public let browserVersion: String
        public let platform: String
        public let mobile: Bool
    }
    
    public struct Event: Codable {
        public let event_key: String
        public let email: String?
        public let percent_viewed: Double
        public let media_id: String
        public let media_name: String
        public let embed_url: String?

//        public let media_url: String
//        public let user_agent_details: UserAgentDetails
    }
    
}

extension Wistia {
    
    public func showVisitors(search: String, page: Int, per_page: Int, completionHandler: @escaping ([Stats.Visitor]?, Error?) -> Void) {
        let route: Wistia.StatsRoute = .visitors
        let request = createRequest(route, httpMethod: .get, queryParams: [
            "search": search,
            "per_page": "\(per_page)",
            "page": page.description
            ], httpBody: nil)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error)
                return completionHandler([], error)
            }
            
            parse(data: data, completionHandler: completionHandler)
        }
        task.resume()
    }
    
    public func showEventsForVisitor(visitorKey: String, page: Int, per_page: Int, completionHandler: @escaping ([Stats.Event]?, Error?) -> Void) {
        let route: Wistia.StatsRoute = .events
        let request = createRequest(route, httpMethod: .get, queryParams: [
            "visitor_key": visitorKey,
            "per_page": "\(per_page)",
            "page": page.description
            ], httpBody: nil)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error)
                return completionHandler([], error)
            }
            
            parse(data: data, completionHandler: completionHandler)
        }
        task.resume()
    }
    
}
