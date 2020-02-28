
//
//  StickerModel.swift
//  Action
//
//  Created by ToanDK on 9/10/19.
//

import Foundation
import ObjectMapper
import DTMvvm

public class StickerModel: Model {
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
    
    override public func mapping(map: Map) {
        imageURL <- map["url"]
        id <- map["id"]
        localFileName <- map["filename"]
    }
}

class GroupStickerModel: Model {
    var url: String = ""
    var fileName: String = ""
    var id: Int = 1
    
    override func mapping(map: Map) {
        url <- map["url"]
        fileName <- map["filename"]
        id <- (map["id"])
    }
}
