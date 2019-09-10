
//
//  StickerModel.swift
//  Action
//
//  Created by ToanDK on 9/10/19.
//

import Foundation
import ObjectMapper
import DTMvvm

class StickerModel: Model {
    var id: String = ""
    var imageURL: String = ""
    var localFileName: String = ""
    
    convenience init(withFileName name: String) {
        self.init(JSON: [:])!
        localFileName = name
    }
    
    convenience init(withUrl imageUrl: String) {
        self.init(JSON: ["url": imageUrl])!
    }
    
    override func mapping(map: Map) {
        imageURL <- map["url"]
        id <- map["id"]
        localFileName <- map["filename"]
    }
}
