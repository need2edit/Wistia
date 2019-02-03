import XCTest
@testable import Wistia

final class WistiaTests: XCTestCase {

    lazy var testAPIPassword =  "abc1234567890"
    lazy var wistia = Wistia(api_password: testAPIPassword)
    
    func test_DataAPI_Setup() {
        XCTAssertEqual(wistia.api_password, testAPIPassword)
        XCTAssertEqual(wistia.debugMode, .off)
        XCTAssertEqual(wistia.baseURL, "https://api.wistia.com/v1/")
        XCTAssertEqual(wistia.session, URLSession.shared)
    }
    
    func test_DefaultProjects_Request() {
        let request = wistia.createRequest(Wistia.DataRoute.projects)
        // defaults to no body data
        XCTAssertNil(request.httpBody)
        // must have a URL
        XCTAssertNotNil(request.url)
        // must have a value of "GET"
        XCTAssertEqual(request.httpMethod, HTTPMethod.get.rawValue)
        
        let components = URLComponents(string: request.url!.absoluteString)!
        
        // host should be api.wistia.com
        XCTAssertEqual(components.host, "api.wistia.com")
        
        let queryNames = components.queryItems?.compactMap { $0.name }
        
        // every request has to have an API password
        // this could be moved to an adapter pattern in another framework
        
        XCTAssertTrue(queryNames!.contains("api_password"))
        
        // must have api_password with the value "abc1234567890"
        for queryItem in components.queryItems! {
            if queryItem.name == "api_password" {
                XCTAssertEqual(queryItem.value!, testAPIPassword)
            }
        }
        
        // must end with projects.json
        XCTAssertEqual(components.path, "/v1/projects.json")
    }
    
    func test_DefaultMedias_Request() {
        let request = wistia.createRequest(Wistia.DataRoute.medias)
        // defaults to no body data
        XCTAssertNil(request.httpBody)
        // must have a URL
        XCTAssertNotNil(request.url)
        // must have a value of "GET"
        XCTAssertEqual(request.httpMethod, HTTPMethod.get.rawValue)
        
        let components = URLComponents(string: request.url!.absoluteString)!
        
        // host should be api.wistia.com
        XCTAssertEqual(components.host, "api.wistia.com")
        
        let queryNames = components.queryItems?.compactMap { $0.name }
        
        // every request has to have an API password
        // this could be moved to an adapter pattern in another framework
        
        XCTAssertTrue(queryNames!.contains("api_password"))
        
        // must have api_password with the value "abc1234567890"
        for queryItem in components.queryItems! {
            if queryItem.name == "api_password" {
                XCTAssertEqual(queryItem.value!, testAPIPassword)
            }
        }
        
        // must end with projects.json
        XCTAssertEqual(components.path, "/v1/medias.json")
    }
    
    func test_DefaultMediaRequest() {
        let id = "abcd123"
        let request = wistia.createRequest(Wistia.DataRoute.media(id: id))
        // defaults to no body data
        XCTAssertNil(request.httpBody)
        // must have a URL
        XCTAssertNotNil(request.url)
        // must have a value of "GET"
        XCTAssertEqual(request.httpMethod, HTTPMethod.get.rawValue)
        
        let components = URLComponents(string: request.url!.absoluteString)!
        
        // host should be api.wistia.com
        XCTAssertEqual(components.host, "api.wistia.com")
        
        let queryNames = components.queryItems?.compactMap { $0.name }
        
        // every request has to have an API password
        // this could be moved to an adapter pattern in another framework
        
        XCTAssertTrue(queryNames!.contains("api_password"))
        
        // must have api_password with the value "abc1234567890"
        for queryItem in components.queryItems! {
            if queryItem.name == "api_password" {
                XCTAssertEqual(queryItem.value!, testAPIPassword)
            }
        }
        
        // must end with projects.json
        XCTAssertEqual(components.path, "/v1/medias/\(id).json")
    }
    
    func test_DefaultMediaCaptionsRequest() {
        let id = "abcd123"
        let request = wistia.createRequest(Wistia.DataRoute.mediaCaptions(id: id))
        // defaults to no body data
        XCTAssertNil(request.httpBody)
        // must have a URL
        XCTAssertNotNil(request.url)
        // must have a value of "GET"
        XCTAssertEqual(request.httpMethod, HTTPMethod.get.rawValue)
        
        let components = URLComponents(string: request.url!.absoluteString)!
        
        // host should be api.wistia.com
        XCTAssertEqual(components.host, "api.wistia.com")
        
        let queryNames = components.queryItems?.compactMap { $0.name }
        
        // every request has to have an API password
        // this could be moved to an adapter pattern in another framework
        
        XCTAssertTrue(queryNames!.contains("api_password"))
        
        // must have api_password with the value "abc1234567890"
        for queryItem in components.queryItems! {
            if queryItem.name == "api_password" {
                XCTAssertEqual(queryItem.value!, testAPIPassword)
            }
        }
        
        // must end with projects.json
        XCTAssertEqual(components.path, "/v1/medias/\(id)/captions.json")
    }
    
    static var allTests = [
        ""
    ]
}
