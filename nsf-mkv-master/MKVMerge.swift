//
//  MKVMerge.swift
//  nsf-mkv-master
//
//  Created by nsfish on 2020/4/21.
//  Copyright © 2020 nsfish. All rights reserved.
//

import Foundation

class MKVMerge {
    
    class func removeAllSubtitlesFrom(file: URL, option: Option) throws {
        let fileName = file.lastPathComponent
        let newFileName = file.deletingPathExtension().lastPathComponent + "_no_subtitles" + ".mkv"
        let dirURL = URL.init(fileURLWithPath: file.deletingLastPathComponent().path)

        let task = Process()
        task.currentDirectoryURL = dirURL
        task.executableURL = URL.init(fileURLWithPath: "/usr/local/bin/mkvmerge")

        // TODO: 如何过滤输出的提示信息？
        // https://stackoverflow.com/questions/29548811/real-time-nstask-output-to-nstextview-with-swift
//        let output = Pipe()
//        task.standardOutput = output
        
        // 防止在 Console 中输出 error log
        task.standardError = Pipe()

        task.arguments = ["-o", newFileName, Operation.removeAllSubtitles.rawValue, fileName]

        task.launch()
        task.waitUntilExit()
        
        if (option == .replaceOriginal) {
            let newFileURL = dirURL.appendingPathComponent(newFileName)
            try FileManager.default.removeItem(at: file)
            try FileManager.default.moveItem(at: newFileURL, to: file)
        }
    }
}
