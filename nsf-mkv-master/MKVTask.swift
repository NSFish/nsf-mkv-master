//
//  MKVTask.swift
//  nsf-mkv-master
//
//  Created by nsfish on 2020/5/5.
//  Copyright © 2020 nsfish. All rights reserved.
//

import Foundation

class MKVTask {
    
    class func detectMKVFilesIn(directory: URL) throws -> [URL] {
        let items = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: .none, options: .skipsHiddenFiles)
        let mkvFiles = items.filter { url -> Bool in
            return url.pathExtension.lowercased() == "mkv"
        }
        
        if (mkvFiles.count == 0) {
            // 在指定目录下没找到 mkv 文件
            throw NSFMKVError.dummy
        }
        
        return mkvFiles
    }
    
    @discardableResult class func startTask(with executableURL: URL,
                                            arguments: [String],
                                            showOutput: Bool = false) -> [String] {
        let task = Process()
        task.currentDirectoryURL = directory
        task.executableURL = executableURL
        task.arguments = arguments
        
        let outputPipe = Pipe()
        if !showOutput {
            task.standardOutput = outputPipe
        }
        
        // 防止在 Console 中输出 error log
        task.standardError = Pipe()
        
        task.launch()
        
        var output = [String]()
        if !showOutput {
            // https://stackoverflow.com/a/29519615
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: outputData, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                output = string.components(separatedBy: "\n")
            }
        }
        
        task.waitUntilExit()
        
        //        let status = task.terminationStatus
        
        return output
    }
}
