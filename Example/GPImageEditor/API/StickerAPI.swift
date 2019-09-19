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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getStickerList:
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
        }
    }
    
    var task: Task {
        switch self {
        case .getStickerList(let page):
            let params = [
                "page" : page
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        }
    }
}
