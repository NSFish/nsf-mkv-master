//
//  MKV.swift
//  nsf-mkv-master
//
//  Created by nsfish on 2020/5/5.
//  Copyright © 2020 nsfish. All rights reserved.
//

import Foundation

class MKV {
    
    enum Operation: String {        
        case remove
        case modify
    }
    
    enum Target: String {
        case title
        case track
        case other
    }

    enum TrackType: String {
        case audio
        case subtitles
        case other
    }
    
    enum Language : String {
        case jpn
        case eng
        case rus
        case other
    }
    
    class Track {
        let id: String
        let type: TrackType
        let language: Language

        init(id: String, type: String, language: String) {
            self.id = id
            
            // TODO: 这种 ?? 应该可以优化
            // https://www.latenightswift.com/2019/02/04/unknown-enum-cases/
            self.type = TrackType.init(rawValue: type) ?? .other
            self.language = Language.init(rawValue: language) ?? .other
        }
    }
}
