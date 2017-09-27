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

struct productList: Decodable {
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

class Networking {
    
    static func getComments(id: Int, completion: @escaping ([Comment]) -> Void) {
        var commentsURL = URL(string: "https://api.producthunt.com/v1/comments")
        
        let urlParams = ["search[post_id":String(describing:id)]
        
        commentsURL?.appendingQueryParameters(urlParams)
        
        //let dispatch = DispatchGroup()
        
        let session = URLSession.shared
        
        var request = URLRequest(url: commentsURL!)
        
        request.httpMethod = "GET"
        
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer 5591fd155cf2db08e3657d05d5775c4ccf7a9d6f71c60ddacdb9ea7d9c4b5f73", forHTTPHeaderField: "Authorization")
        request.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        
        var comments = [String]()
        
        //dispatch.enter()
        
        var commentz = [Comment]()
        session.dataTask(with: request) { (data, resp, err) in
        

            if let data = data {
                
                let productHuntComments = try? JSONDecoder().decode(commentList.self, from: data)
                
                let commentsList = productHuntComments?.comments
                
                commentz = commentsList!
                
                DispatchQueue.main.async {
                    completion(commentz)
                }
                
                
                
                
                //dispatch.leave()
            } else {
                //dispatch.leave()
            }
            
            
        }.resume()
        
        
    }
    
   
    
    static func getPosts(completion: @escaping ([Product]) -> Void) {
        
         let date = Date()
        
        var productHuntUrl = URL(string: "https://api.producthunt.com/v1/posts")
        
        let urlParams = ["search[featured]": "True",
                         "scope": "public",
                         "created_at": String(describing: date),
                         "per_page": "20"]
        productHuntUrl?.appendingQueryParameters(urlParams)
        
        let dispatch = DispatchGroup()
        
        let session = URLSession.shared
        
        var request = URLRequest(url: productHuntUrl!)
        
        
        
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer 5591fd155cf2db08e3657d05d5775c4ccf7a9d6f71c60ddacdb9ea7d9c4b5f73", forHTTPHeaderField: "Authorization")
        request.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        
        var posts = [Product]()
        
        //dispatch.enter()
        
        session.dataTask(with: request) { (data, resp, err) in
            
            if let data = data {
                
                let productHunt = try? JSONDecoder().decode(productList.self, from: data)
                
                let productHuntList = productHunt?.posts
                
                posts = productHuntList!
                completion(posts)
                  
                //dispatch.leave()
            } else {
                //dispatch.leave()
                fatalError("Networking failed")
            }
            
        }.resume()
        
//        dispatch.notify(queue: .main, execute: {
//
//            completion(posts)
//        })
        
    }
    
}

extension URL {
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
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





