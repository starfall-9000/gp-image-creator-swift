//
//  StickerAPI.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/11/19.
//

import Foundation
import Moya

enum StickerAPI {
    case getStickerList(page: Int)
    case getFrame(fromCache: Bool)
}

extension StickerAPI: TargetType {
    var headers: [String : String]? {
        return ["Authorization": "Bearer \(GPImageEditorConfigs.userToken)"]
    }
    
    var baseURL: URL { return URL(string: GPImageEditorConfigs.apiDomain)! }
    
    var path: String {
        switch self {
        case .getStickerList:
            return GPImageEditorConfigs.stickersAPIPath
        case .getFrame:
            return GPImageEditorConfigs.frameAPIPath
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getStickerList, .getFrame:
            return .get
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var sampleData: Data {
        switch self {
        case .getStickerList:
            guard let url = GPImageEditorBundle.getBundle().url(forResource: "stickers_api", withExtension: "json")
                else { return Data() }
            let contentData = try? Data(contentsOf: url)
            return contentData ?? Data()
        case .getFrame:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        case .getStickerList(let page):
            let params: [String: Any] = [
                "package_id": "1",
                "page" : page
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case .getFrame:
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        }
    }
}

extension StickerAPI: MoyaCacheable {
    var cachePolicy: MoyaCacheablePolicy {
        switch self {
        case .getStickerList:
            return .returnCacheDataElseLoad
        case .getFrame(let fromCache):
            return fromCache ? .returnCacheDataElseLoad : .reloadIgnoringLocalCacheData
        }
    }
}
