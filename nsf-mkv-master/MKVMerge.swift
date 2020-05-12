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
    
    func unifyTitleWithFileNameForFile(at url: URL) throws {
        let fileName = url.lastPathComponent
        let title = MKVInfo.shared.titleOfFile(at: url)
        if title == fileName {
            print("无须处理 " + fileName + ", 跳过.")
        }
        else {
            try executeTask(with: url,
                            operation: ["--title", url.lastPathComponent],
                            showOutput: true)
        }
    }
    
    func modifyTrackNameInFile(at url: URL, type: MKV.TrackType, language: MKV.Language?, trackID: String?, trackName: String) throws {
        if let language = language {
            print("开始处理 " + url.lastPathComponent + "...")
            
            let tracks = try MKVInfo.shared.tracksInFile(at: url, type: type)
            
            if let matchedTrackIDs = tracks.filter({ $0.language == language }).map({ $0.id }).first {
                try executeTask(with: url,
                                operation: ["--track-name", matchedTrackIDs + ":" + trackName],
                                showOutput: true)
            }
            else {
                throw NSFMKVError.dummy
            }
        }
    }
    
    func removeTrackFromFile(at url: URL, type: MKV.TrackType, option: Option, language: MKV.Language?, trackID: String?) throws {
        if let language = language {
            let tracks = try MKVInfo.shared.tracksInFile(at: url, type: type)
            
            let remainedTrackIDs = tracks.filter() { option == .reverse ? $0.language == language : $0.language != language }
                .map { $0.id }
            
            if tracks.count == 1
                && remainedTrackIDs.count == 1 {
                print("无须处理 " + url.lastPathComponent + ", 跳过.")
                // MKV 文件中本身已经只剩下指定语言的 track 了，无须混流，直接略过
            }
            else if remainedTrackIDs.count > 0 {
                print("开始处理 " + url.lastPathComponent + "...")
                try executeTask(with: url,
                                operation: ["-a", remainedTrackIDs.joined(separator: ",")],
                                showOutput: true)
            }
            else {
                // TODO: 找不到指定 type、指定语言的 track
                if option == .reverse {
                    throw NSFMKVError.dummy
                }
            }
        }
    }
    
    func removeAllTracksFromFile(at url: URL, type: MKV.TrackType, option: Option) throws {
        let operation: String = {
            switch type {
            case .audio: return "--no-audio"
            case .subtitles: return "--no-subtitles"
            case .other: return ""
            }
        }()
        
        if operation != MKV.TrackType.other.rawValue {
            let tracks = try MKVInfo.shared.tracksInFile(at: url, type: type)
            if tracks.count == 0 {
                print("无须处理 " + url.lastPathComponent + ", 跳过.")
            }
            else {
                print("开始处理 " + url.lastPathComponent + "...")
                try executeTask(with: url, operation: [operation], showOutput: true)
            }
        }
    }
}

// Private
private extension MKVMerge {
    
    func executeTask(with fileURL: URL, operation: [String],
                     option: Option = .replaceOriginal,
                     showOutput: Bool = false) throws {
        let fileName = fileURL.lastPathComponent
        let newFileName = fileURL.deletingPathExtension().lastPathComponent + "_temp" + ".mkv"
        
        MKVTask.startTask(with: executableURL,
                          arguments: ["-o", newFileName] + operation + [fileName],
                          showOutput: showOutput)
        
        // TODO: let dirURL = file.deletingLastPathComponent() 为什么不行？
        let dirURL = URL.init(fileURLWithPath: fileURL.deletingLastPathComponent().path)
        let newFileURL = dirURL.appendingPathComponent(newFileName)
        try FileManager.default.removeItem(at: fileURL)
        try FileManager.default.moveItem(at: newFileURL, to: fileURL)
    }
}
