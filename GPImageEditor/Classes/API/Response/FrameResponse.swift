//
//  FrameResponse.swift
//  Action
//
//  Created by An Binh on 1/13/20.
//

import Foundation
import RxSwift
import Moya
import DTMvvm
import ObjectMapper

public class FrameModel: Model {
    var id: String = ""
    var title: String = ""
    var smallThumb: String = ""
    var mediumThumb: String = ""
    var largeThumb: String = ""
    var status: Int = 1
    var desc: String = ""
    var createAt: Int64 = 0
    var updateAt: Int64 = 0
    
    convenience init() {
        self.init(JSON: [String: Any]())!
    }
    
    override public func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        smallThumb <- map["media.small"]
        mediumThumb <- map["media.medium"]
        largeThumb <- map["media.large"]
        status <- map["status"]
        desc <- map["description"]
        createAt <- map["createAt"]
        updateAt <- map["updateAt"]
    }
}

public class FrameResponse: Model {
    var code: ResponseCode = .success
    var message: String = ""
    var frames: [FrameModel] = []
    
    convenience init() {
        self.init(JSON: [String: Any]())!
    }
    
    override public func mapping(map: Map) {
        code <- (map["code"], EnumTransform<ResponseCode>())
        message <- map["message"]
        frames <- map["data"]
    }
}
