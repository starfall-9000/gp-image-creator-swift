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
    public var id: Int = 0
    public var title: String = ""
    public var smallThumb: String = ""
    public var mediumThumb: String = ""
    public var largeThumb: String = ""
    public var status: Int = 1
    public var desc: String = ""
    public var createAt: Int64 = 0
    public var updateAt: Int64 = 0
    
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
    public var message: String = ""
    public var frames: [FrameModel] = []
    
    convenience init() {
        self.init(JSON: [String: Any]())!
    }
    
    override public func mapping(map: Map) {
        code <- (map["code"], EnumTransform<ResponseCode>())
        message <- map["message"]
        frames <- map["data"]
    }
}
