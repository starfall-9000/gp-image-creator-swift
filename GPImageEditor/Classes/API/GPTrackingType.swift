//
//  GPTrackingType.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/28/19.
//

import Foundation

struct PEAnalyticsEvent {
    static let PHOTO_EDITOR_SHOWN = "photo_editor_shown"
    static let PHOTO_EDITOR_FINISHED = "photo_editor_finished"
    static let PHOTO_EDITOR_CANCEL = "photo_editor_cancel"
    
    static let FILTER_ID = "filter_id"
    static let STICKER_IDS = "sticker_ids"
    static let EMOJI_IDS = "emoji_ids"
    static let HAVE_TEXT = "have_text"
    static let HAVE_CROP = "have_crop"
}

public protocol GPTrackingType {
    func recordEvent(_ name: String, params: [AnyHashable : Any]?)
}

extension GPTrackingType {
    func recordPEShown() {
        recordEvent(PEAnalyticsEvent.PHOTO_EDITOR_SHOWN, params: nil)
    }
}
