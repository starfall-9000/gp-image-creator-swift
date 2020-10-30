//
//  StickerAPI.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/11/19.
//

import Foundation
import Moya

public enum StickerGroupType: String {
    case imageCreator = "image_creator"
    case story = "story"
}

enum StickerAPI {
    case getStickerList(page: Int, packageId: String, fromCache: Bool)
    case getFrame(fromCache: Bool)
    case getPackagesInGroup(StickerGroupType, fromCache: Bool)
}

extension StickerAPI: TargetType {
    var headers: [String : String]? {
        return ["Authorization": "Bearer \(GPImageEditorConfigs.userToken)"]
    }
    
    var baseURL: URL {
        switch self {
        case .getStickerList(_, let packageId, _):
            let path = GPImageEditorConfigs.stickersAPIPath + "?package_id=\(packageId)"
            return URL(string: GPImageEditorConfigs.apiDomain + path)!
        default:
            return URL(string: GPImageEditorConfigs.apiDomain)!
        }
        
        
    }
    
    var path: String {
        switch self {
        case .getStickerList:
            return ""
        case .getFrame:
            return GPImageEditorConfigs.frameAPIPath
        case .getPackagesInGroup:
            return GPImageEditorConfigs.groupStickerPath
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getStickerList, .getFrame, .getPackagesInGroup:
            return .get
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var sampleData: Data {
        switch self {
        case .getStickerList, .getPackagesInGroup:
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
        case .getStickerList:
            return .requestParameters(parameters: [:], encoding: URLEncoding.httpBody)
        case .getFrame:
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        case .getPackagesInGroup(let type, _):
            let params = ["type": type.rawValue]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
}

extension StickerAPI: MoyaCacheable {
    var cachePolicy: MoyaCacheablePolicy {
        switch self {
        case .getStickerList(_, _, let fromCache), .getPackagesInGroup(_, let fromCache), .getFrame(let fromCache):
            return fromCache ? .returnCacheDataElseLoad : .reloadIgnoringLocalCacheData
        default:
            return .returnCacheDataElseLoad
        }
    }
}
