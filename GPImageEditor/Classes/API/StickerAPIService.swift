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

class GroupStickerResponse: Model {
    var code: ResponseCode = .success
    var message: String = ""
    var groups: [GroupStickerModel] = []
    
    override func mapping(map: Map) {
        code <- (map["code"], EnumTransform<ResponseCode>())
        message <- map["message"]
        groups <- map["data"]
    }
}

public class StickerAPIService {
    private let stickerProvider = MoyaProvider<StickerAPI>(plugins: [MoyaCacheablePlugin(), NetworkLoggerPlugin()])
    
    func getStickerList(page: Int, packageIds: [String],
                        fromCache: Bool) -> Single<StickerResponse> {
        return stickerProvider.rx
            .request(.getStickerList(page: page, packageIds: packageIds,
                                     fromCache: fromCache))
            .mapObject(StickerResponse.self)        
    }
    
    public func getFrame(fromCache: Bool = true) -> Single<FrameResponse> {
        return stickerProvider.rx
            .request(.getFrame(fromCache: fromCache))
            .mapObject(FrameResponse.self)
    }
    
    func getPackages(group: StickerGroupType, fromCache: Bool) -> Single<GroupStickerResponse> {
        return stickerProvider.rx
            .request(.getPackagesInGroup(group, fromCache: fromCache))
            .mapObject(GroupStickerResponse.self)
    }
}
