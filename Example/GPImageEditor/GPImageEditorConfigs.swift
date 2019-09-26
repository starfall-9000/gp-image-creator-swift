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
    static public var colorSet: [(UIColor, UIColor)] = [(.white, .black), (.black, .white), (.fromHex("#FF4C82"), .white), (.fromHex("#1A99F4"), .white), (.fromHex("#F7D925"), .white), (.fromHex("#6FBE49"), .white), (.fromHex("#F87376"), .white), (.fromHex("#D48E15"), .white), (.fromHex("#5168D7"), .white), (.fromHex("#0B3688"), .white)]
    
    static public var fontSet: [(String, String)] = [("BalooPaaji", "BalooPaaji-Regular"), ("Nunito", "Nunito-Regular"), ("Oswald", "Oswald-Regular"), ("Hepta", "HeptaSlab-Regular"), ("DancingScript", "DancingScript-Regular")]
}
