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
    private let executableURL: URL
    
    private init() {
        executableURL = URL.init(fileURLWithPath: "/usr/local/bin/mkvmerge")
    }
    
    func modifyTrackNameIn(file: URL, type: MKV.TrackType, language: MKV.Language?, trackID: String?, trackName: String) throws {
        if let language = language {
            let tracks = try MKVInfo.shared.tracks(in: file, type: type)
            
            if let matchedTrackIDs = tracks.filter({ $0.language == language }).map({ $0.id }).first {
                try executeTask(with: file,
                                operation: ["--track-name", matchedTrackIDs + ":" + trackName])
            }
            else {
                throw NSFMKVError.dummy
            }
        }
    }
    
    func removeTrackFrom(file: URL, type: MKV.TrackType, option: Option, language: MKV.Language?, trackID: String?) throws {
        if let language = language {
            let audioTracks = try MKVInfo.shared.tracks(in: file, type: type)
            
            let remainAudioTrackIDs = audioTracks.filter() { option == .reverse ? $0.language == language : $0.language != language }
                .map { $0.id }
            if remainAudioTrackIDs.count > 0 {
                try executeTask(with: file, operation: ["-a", remainAudioTrackIDs.joined(separator: ",")])
            }
            else {
                // TODO: 找不到指定 type、指定语言的 track
                if option == .reverse {
                    throw NSFMKVError.dummy
                }
            }
        }
    }
    
    func removeAllTracksFrom(file: URL, type: MKV.TrackType, option: Option) throws {
        let operation: String = {
            switch type {
            case .audio: return "--no-audio"
            case .subtitles: return "--no-subtitles"
            case .other: return ""
            }
        }()
        
        if operation != MKV.TrackType.other.rawValue {
            try executeTask(with: file, operation: [operation])
        }
    }
}

// Private
private extension MKVMerge {
    
    func executeTask(with fileURL: URL, operation: [String], option: Option = .replaceOriginal) throws {
        let fileName = fileURL.lastPathComponent
        let newFileName = fileURL.deletingPathExtension().lastPathComponent + "_temp" + ".mkv"
        
        MKVTask.startTask(with: executableURL, arguments: ["-o", newFileName] + operation + [fileName])
        
        // TODO: let dirURL = file.deletingLastPathComponent() 为什么不行？
        let dirURL = URL.init(fileURLWithPath: fileURL.deletingLastPathComponent().path)
        let newFileURL = dirURL.appendingPathComponent(newFileName)
        try FileManager.default.removeItem(at: fileURL)
        try FileManager.default.moveItem(at: newFileURL, to: fileURL)
    }
}
