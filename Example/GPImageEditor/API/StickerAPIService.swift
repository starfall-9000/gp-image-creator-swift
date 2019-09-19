//
//  StickerService.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/11/19.
//

import Foundation
import RxSwift
import Moya
import DTMvvm
import ObjectMapper

enum ResponseCode: Int {
    case success = 1
    case fail = 0
}

class StickerResponse: Model {
    var code: ResponseCode = .success
    var message: String = ""
    var stickers: [StickerModel] = []
    
    convenience init() {
        self.init(JSON: [String: Any]())!
    }
    
    override func mapping(map: Map) {
        code <- (map["code"], EnumTransform<ResponseCode>())
        message <- map["message"]
        stickers <- map["data"]
    }
}

class StickerAPIService {
    private let stickerProvider = GPImageEditorConfigs.debugAPI
        ? MoyaProvider<StickerAPI>(stubClosure: MoyaProvider.immediatelyStub, plugins: [NetworkLoggerPlugin(verbose: true)])
        : MoyaProvider<StickerAPI>()
    
    func getStickerList(page: Int) -> Single<StickerResponse> {
        return stickerProvider.rx
            .request(.getStickerList(page: page))
//            .handleUnauthorizedError()
            .mapObject(StickerResponse.self)        
    }
}
