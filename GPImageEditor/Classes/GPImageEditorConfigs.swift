//
//  GPImageEditorConfigs.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/11/19.
//

import Foundation
import DTMvvm

public class GPImageEditorConfigs {
    
    static public var apiDomain: String = "https://staging-api.gapo.vn/main/v1.1"
    static public var stickersAPIPath: String = "/stickers"
    static public var userToken = ""
    static public var debugAPI = false
    static public var dependencyManager: DependencyManager? = nil {
        didSet {
            dependencyManager?.registerService(Factory<StickerAPIService> { StickerAPIService() })
        }
    }
}
