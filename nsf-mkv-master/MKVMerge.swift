//
//  MKVMerge.swift
//  nsf-mkv-master
//
//  Created by nsfish on 2020/4/21.
//  Copyright © 2020 nsfish. All rights reserved.
//

import Foundation

class MKVMerge {
    
    static let shared = MKVMerge()
    let executableURL: URL
    
    private init() {
        executableURL = URL.init(fileURLWithPath: "/usr/local/bin/mkvmerge")
    }
    
    func removeTrackFrom(file: URL, type: MKV.TrackType, option: Option, language: MKV.Language?, trackID: String?) throws {
        if let language = language {
            let audioTracks = try MKVInfo.shared.tracks(in: file, type: MKV.TrackType.audio)
            
            let fileName = file.lastPathComponent
            let newFileName = file.deletingPathExtension().lastPathComponent + "_temp" + ".mkv"
            
            let remainAudioTrackIDs = audioTracks.filter() { option == .reverse ? $0.language == language : $0.language != language }
                .map { $0.id }
                .joined(separator: ",")
            let arguments = ["-o", newFileName, "-a", remainAudioTrackIDs, fileName]
            MKVTask.startTask(with: executableURL, arguments: arguments)
            
            let dirURL = URL.init(fileURLWithPath: file.deletingLastPathComponent().path)
            let newFileURL = dirURL.appendingPathComponent(newFileName)
            try FileManager.default.removeItem(at: file)
            try FileManager.default.moveItem(at: newFileURL, to: file)
        }
    }
    
    func removeAllTracksFrom(file: URL, type: MKV.TrackType, option: Option) throws {
        let fileName = file.lastPathComponent
        let newFileName = file.deletingPathExtension().lastPathComponent + "_temp" + ".mkv"
        
        let operation: String = {
            switch type {
            case .audio: return "--no-audio"
            case .subtitles: return "--no-subtitles"
            case .other: return ""
            }
        }()
        
        let arguments = ["-o", newFileName, operation, fileName]
        MKVTask.startTask(with: executableURL, arguments: arguments)
        
        //        if (option == .replaceOriginal) {
        // TODO: let dirURL = file.deletingLastPathComponent() 为什么不行？
        let dirURL = URL.init(fileURLWithPath: file.deletingLastPathComponent().path)
        let newFileURL = dirURL.appendingPathComponent(newFileName)
        try FileManager.default.removeItem(at: file)
        try FileManager.default.moveItem(at: newFileURL, to: file)
        //        }
    }
}
