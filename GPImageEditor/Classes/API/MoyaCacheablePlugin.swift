//
//  MoyaCacheablePlugin.swift
//  GPImageEditor_Example
//
//  Created by ToanDK on 9/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Moya

public protocol MoyaCacheable {
    typealias MoyaCacheablePolicy = URLRequest.CachePolicy
    var cachePolicy: MoyaCacheablePolicy { get }
}

public final class MoyaCacheablePlugin: PluginType {
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if let moyaCachableProtocol = target as? MoyaCacheable {
            var cachableRequest = request
            cachableRequest.cachePolicy = moyaCachableProtocol.cachePolicy
            return cachableRequest
        }
        return request
    }
}
