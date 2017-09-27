//
//  Networking.swift
//  ProductHunt
//
//  Created by Sunny Ouyang on 9/24/17.
//  Copyright © 2017 Sunny Ouyang. All rights reserved.
//

import Foundation


/*Right now I have my tableview set up and my tableview cell set up
Things to do:



4) Populate our tableview cells
 
 
 
 */

struct Comment {
   var body: String?
    
    init(body: String) {
        self.body = body
    }
    
}

extension Comment: Decodable {
    
    enum commentContainerKey: String, CodingKey {
        case body
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: commentContainerKey.self)
        let comment = try container.decodeIfPresent(String.self, forKey: .body)
        
        self.init(body: comment!)
    }
}

struct commentList: Decodable {
    let comments: [Comment]
}

struct Product {
    var name: String?
    var tagline: String?
    var votes: Int?
    var imageURL: String?
    var id: Int?
    
    init(name: String, tagline: String, votes: Int, imageURL: String, id: Int) {
        self.name = name
        self.tagline = tagline
        self.votes = votes
        self.imageURL = imageURL
        self.id = id
    }
    
}

struct ProductList: Decodable {
    var posts: [Product]
}

extension Product: Decodable {
    
    enum containerKeys: String, CodingKey {
        case name
        case tagline
        case votes = "votes_count"
        case thumbnail
        case id
        
    }
    
    enum thumbnailKeys: String, CodingKey {
        case imageURL = "image_url"
    }
    
    init(from decoder: Decoder) throws {
        let topContainer = try decoder.container(keyedBy: containerKeys.self)
        let imageContainer = try topContainer.nestedContainer(keyedBy: thumbnailKeys.self, forKey: .thumbnail)
        let name = try topContainer.decodeIfPresent(String.self, forKey: .name)
        let tagline = try topContainer.decodeIfPresent(String.self, forKey: .tagline)
        let id = try topContainer.decodeIfPresent(Int.self, forKey: .id)
        
         var votes = try topContainer.decodeIfPresent(Int.self, forKey: .votes)
        
        if votes == nil {
            votes = 0
        }
            
        
            
        
        let imageURL = try imageContainer.decodeIfPresent(String.self, forKey: .imageURL)
        
        self.init(name: name!, tagline: tagline!, votes: votes!, imageURL: imageURL!, id: id!)
        
    }
}




//enum Route {
//    case post
//    case comments(id: String)
//
//    func path() -> String {
//        switch self {
//        case .post:
//            return "/posts"
//        case .comments:
//            return "/comments/"
//        }
//
//    }
//
//    func urlParameters() -> [String: String] {
//        switch self {
//        case .post:
//            return [:]
//        case let .comments(id):
//            return ["search[post_id]": "\(id)"]
//        }
//    }
//
//    func headers() -> [String: String] {
//        return ["Authorization": "Bearer 5591fd155cf2db08e3657d05d5775c4ccf7a9d6f71c60ddacdb9ea7d9c4b5f73"]
//    }
//
//}

//class Networking {
//
//    static let instance = Networking()
//
//    let baseURL = "https://api.producthunt.com/v1"
//    let session = URLSession.shared
//
//
//    func fetch(route: Route,  completion: @escaping (Data) -> Void) {
//        let fullPath = baseURL.appending(route.path())
//        var url = URL(string: fullPath)!
//        url = url.appendingQueryParameters(route.urlParameters())
//
//        var request = URLRequest(url: url)
//        request.allHTTPHeaderFields = route.headers()
//
//
//        session.dataTask(with: request) { (data, res, err) in
//            guard let data = data else {return}
//
//            completion(data)
//        }
//    }
//
//}
enum Route {
    case post
    case comment(postId: String)
    
    func path() -> String {
        switch self {
        case .post:
            return "posts"
        case .comment:
            return "comments"
        }
    }
    
    func headers() -> [String: String] {
        return ["Authorization": "Bearer 5591fd155cf2db08e3657d05d5775c4ccf7a9d6f71c60ddacdb9ea7d9c4b5f73"]
    }
    
    func urlParameters() -> [String: String] {
        switch self {
        case .post:
            return [:]
        case let .comment(postId):
            return ["search[post_id]": postId]
        }
    }
}


class Networking {
    static let instance = Networking()
    
    let baseURL = "https://api.producthunt.com/v1/"
    let session = URLSession.shared
    
    func fetch(route: Route, model: Decodable, completion: @escaping (Data) -> Void) {
        let fullUrlString = baseURL.appending(route.path())
        
        var url = URL(string: fullUrlString)!
        url = url.appendingQueryParameters(route.urlParameters())
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = route.headers()
        
        session.dataTask(with: request) { (data, res, err) in
            guard let data = data else {return}
            
            let decodeModel = JSONDecoder()
            let model = decodeModel.decode(type(of: model), from: data)
            
            completion(data)
        }
    }
}

extension URL {
    
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        
        let net = Networking.instance
        net.fetch(route: Route.post) { (data) in
            
        }
        
        net.fetch(route: Route.comment(postId: "1")) { (data) in
            
        }
        
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        
        return URL(string: URLString)!
    }
    // This is formatting the query parameters with an ascii table reference therefore we can be returned a json file
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}





