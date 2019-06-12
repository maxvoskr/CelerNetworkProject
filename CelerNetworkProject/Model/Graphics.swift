//
//  Graphics.swift
//  CelerNetworkProject
//
//  Created by Maksym Voskresenskyy on 6/10/19.
//  Copyright © 2019 Maksym Voskresenskyy. All rights reserved.
//

import Foundation

struct Graphic {
    var id: Int
    var imageUrl: String
    var videoUrl: String
    
    init(json: [String: AnyObject]) {
        self.id = json["id"] as? Int ?? -1
        self.imageUrl = json["imageUrl"] as? String ?? ""
        self.videoUrl = json["videoUrl"] as? String ?? ""
    }
}
