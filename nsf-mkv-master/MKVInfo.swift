//
//  MKVInfo.swift
//  nsf-mkv-master
//
//  Created by nsfish on 2020/4/27.
//  Copyright © 2020 nsfish. All rights reserved.
//

import Foundation

class MKVInfo {
    
    static let shared = MKVInfo()
    private let executableURL: URL
    
    private init() {
        executableURL = URL.init(fileURLWithPath: "/usr/local/bin/mkvinfo")
    }
    
    func tracks(in file: URL, type: MKV.TrackType) throws -> [MKV.Track] {
        return try tracks(in: file).filter { $0.type == type }
    }

    func tracks(in file: URL) throws -> [MKV.Track] {
        let fileName = file.lastPathComponent
        let arguments = ["-o", fileName]
        let output = MKVTask.startTask(with: executableURL, arguments: arguments)
        
        let trackInfos = try trackInfosFrom(output: output)
        
        var tracks = [MKV.Track]()
        trackInfos.forEach { trackInfo in
            var trackID = ""
            var trackType = ""
            var trackLanguage = ""
            
//            | + Track
//            |  + Track number: 1 (track ID for mkvmerge & mkvextract: 0)
//            |  + Track UID: 1
//            |  + Track type: video
//            |  + Default track flag: 0
//            |  + Lacing flag: 0
//            |  + Codec ID: V_MPEGH/ISO/HEVC
//            |  + Codec's private data: size 2404 (HEVC profile: Main 10 @L4.0)
//            |  + Default duration: 00:00:00.041708333 (23.976 frames/fields per second for a video track)
//            |  + Language: jpn
            trackInfo.forEach { line in
                if line.contains("|  + Track number:") {
                    trackID = String(line.split(separator: ":").last!.trimmingCharacters(in: CharacterSet.decimalDigits.inverted))
                }
                else if line.contains("|  + Track type:") {
                    trackType = line.split(separator: ":").last!.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                else if line.contains("|  + Language: ") {
                    trackLanguage = line.split(separator: ":").last!.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
            let track = MKV.Track.init(id: trackID,
                                       type: trackType,
                                       language: trackLanguage)
            tracks.append(track)
        }
        
        return tracks
    }
}

private extension MKVInfo {
    
    func trackInfosFrom(output: [String]) throws -> [[String]] {
        // 先找到 "| + Track" 所在行
        guard let trackStartIndex = output.firstIndex(where: { $0.contains("| + Track")}) else {
            throw NSFMKVError.dummy
        }
        
        // 截掉 "| + Track" 所在行之前的内容，再找到 "|+ EBML void"
        var trackLines = Array(output[trackStartIndex + 1...output.count - 1])
        guard let trackEndIndex = trackLines.firstIndex(where: { $0.contains("|+ EBML void")}) else {
            throw NSFMKVError.dummy
        }
        
        trackLines = Array(trackLines[0...trackEndIndex - 1])
        
        return trackLines.split(separator: "| + Track").map { Array($0) }
    }
}
