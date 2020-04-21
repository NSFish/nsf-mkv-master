//
//  main.swift
//  nsf-mkv-master
//
//  Created by nsfish on 2020/4/21.
//  Copyright © 2020 nsfish. All rights reserved.
//

import Foundation

enum ParseError: Error {
    case dummy
}

enum Operation: String {
    case removeAllSubtitles = "--no-subtitles"
}

enum Option: String {
    case replaceOriginal = "--replace-original"
}

var urlString: String!
var operationString: String!
var optionString: String!
for (index, argument) in CommandLine.arguments.enumerated() {
    if (argument == "-dir") {
        urlString = CommandLine.arguments[index + 1]
    }
    else if (argument == "-operation") {
        operationString = CommandLine.arguments[index + 1]
    }
    else if (argument == "-option") {
        optionString = CommandLine.arguments[index + 1]
    }
}

let dirURL = URL.init(fileURLWithPath: urlString)

guard let operation = Operation.init(rawValue: operationString) else {
    throw ParseError.dummy
}

guard let option = Option.init(rawValue: optionString) else {
    throw ParseError.dummy
}

do {
    let items = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: .none, options: .skipsHiddenFiles)
    let mkvFiles = items.filter { url -> Bool in
        return url.pathExtension.lowercased() == "mkv"
    }

    if (mkvFiles.count == 0) {
        // 在指定目录下没找到 mkv 文件
        throw ParseError.dummy
    }

    try mkvFiles.forEach { fileURL in
        try MKVMerge.removeAllSubtitlesFrom(file: fileURL, option: option)
    }

    print("Done.")
} catch let error as NSError {
    print(error)
}












