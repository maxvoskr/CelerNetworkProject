//
//  APINetwork.swift
//  CelerNetworkProject
//
//  Created by Maksym Voskresenskyy on 6/10/19.
//  Copyright © 2019 Maksym Voskresenskyy. All rights reserved.
//

import Foundation

class APINetwork {
    
    static let shared = APINetwork()
    
    func pullGraphicsData(with completion: @escaping ([Graphic], Error?) -> ()) {
        guard let url = URL(string: "http://private-04a55-videoplayer1.apiary-mock.com/pictures") else { return }
        var graphics = [Graphic]()
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
             
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let graphicsArray = json as! NSArray
                
                for graphic in graphicsArray {
                    var graphic = Graphic(json: graphic as! [String : AnyObject])
                    graphics.append(graphic)
                }
                
                completion(graphics, nil)
                
            } catch let jsonError {
                completion(graphics, jsonError)
                print("json error - \(jsonError) ")
            }
        }.resume()
    }
}
