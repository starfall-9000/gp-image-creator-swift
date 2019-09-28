//
//  GPImageEditorConfigs.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/11/19.
//

import Foundation
import DTMvvm
import ObjectMapper

public class PEFontInfo: Model {
    var name: String = ""
    var font: String = ""
    var size: CGFloat = 30
    var inset: CGFloat = 10
    
    override public func mapping(map: Map) {
        name <- map["name"]
        font <- map["font"]
        size <- map["size"]
        inset <- map["inset"]
    }
    
    convenience init() {
        self.init(JSON: [String: Any]())!
    }
}

public class PEColorInfo: Model {
    var bgColor: String = ""
    var textColor: String = ""
    
    override public func mapping(map: Map) {
        bgColor <- map["bg"]
        textColor <- map["text"]
    }
    
    convenience init() {
        self.init(JSON: [String: Any]())!
    }
}

public class GPImageEditorConfigs {
    
    static public var apiDomain: String = "https://staging-api.gapo.vn/sticker/v1.2"
    static public var stickersAPIPath: String = "/sticker"
    static public var userToken = ""
    static public var dependencyManager: DependencyManager? = nil {
        didSet {
            dependencyManager?.registerService(Factory<StickerAPIService> { StickerAPIService() })
        }
    }
    static public var colorSet: [PEColorInfo] = [
        PEColorInfo(JSON: ["bg": "#fff", "text": "#000"])!,
        PEColorInfo(JSON: ["bg": "#000", "text": "#fff"])!,
        PEColorInfo(JSON: ["bg": "#FF4C82", "text": "#fff"])!,
        PEColorInfo(JSON: ["bg": "#1A99F4", "text": "#fff"])!,
        PEColorInfo(JSON: ["bg": "#F7D925", "text": "#fff"])!
    ]
    
    static public var fontSet: [PEFontInfo] = [
        PEFontInfo(JSON: ["name": "Chữ đậm", "font": "BalooPaaji-Regular", "size": 30, "inset": 8])!,
        PEFontInfo(JSON: ["name": "Mềm mại", "font": "JustLovely-Roman", "size": 50, "inset": 5])!,
        PEFontInfo(JSON: ["name": "Tinh nghịch", "font": "Pacifico-Regular", "size": 30, "inset": 10])!]
}
