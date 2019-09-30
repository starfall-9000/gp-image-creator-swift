//
//  GPTrackingType.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/28/19.
//

import Foundation

struct PEAnalyticsEvent {
    static let PHOTO_EDITOR_SHOWN = "Photo Editor Shown"
    static let PHOTO_EDITOR_FINISHED = "Photo Editor Finished"
    static let PHOTO_EDITOR_CANCEL = "Photo Editor Cancel"
    
    static let FILTER_ID = "Filter ID"
    static let STICKER_IDS = "Sticker IDs"
    static let EMOJI_IDS = "Emoji IDs"
    static let HAVE_TEXT = "Have Text"
    static let HAVE_CROP = "Have Crop"
}

public protocol GPTrackingType {
    func recordEvent(_ name: String, params: [AnyHashable : Any]?)
}

extension GPTrackingType {
    func recordPEShown() {
        recordEvent(PEAnalyticsEvent.PHOTO_EDITOR_SHOWN, params: nil)
    }
}
