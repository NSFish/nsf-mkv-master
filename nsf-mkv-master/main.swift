//
//  main.swift
//  nsf-mkv-master
//
//  Created by nsfish on 2020/4/21.
//  Copyright © 2020 nsfish. All rights reserved.
//

import Foundation

enum NSFMKVError: Error {
    case unknownOperation
    case unknownTrackType
    case noFiles
    case dummy
}

enum Option: String {
    case replaceOriginal = "--replace-original"
    case reverse = "--reverse"
    case all = "--all"
    case none
}

var urlString: String!
var operationString: String!
var trackTypeString: String!
var trackLanguage: MKV.Language?
var trackID: String?
var trackName: String?
var optionString: String?
for (index, argument) in CommandLine.arguments.enumerated() {
    if (argument == "-dir") {
        urlString = CommandLine.arguments[index + 1]
    }
    else if (argument == "-operation") {
        operationString = CommandLine.arguments[index + 1]
    }
    else if (argument == "-track-type") {
        trackTypeString = CommandLine.arguments[index + 1]
    }
    else if (argument == "-language") {
        trackLanguage = MKV.Language.init(rawValue: CommandLine.arguments[index + 1])
    }
    else if (argument == "-track-id") {
        trackID = CommandLine.arguments[index + 1]
    }
    else if (argument == "-track-name") {
        trackName = CommandLine.arguments[index + 1]
    }
    else if (argument == "-option") {
        optionString = CommandLine.arguments[index + 1]
    }
}

let directory = URL.init(fileURLWithPath: urlString)

guard let operation = MKV.Operation.init(rawValue: operationString) else {
    throw NSFMKVError.unknownOperation
}

guard let trackType = MKV.TrackType.init(rawValue: trackTypeString) else {
    throw NSFMKVError.unknownTrackType
}

let option = Option.init(rawValue: optionString ?? "") ?? .none

do {
    let mkvFiles = try MKVTask.detectMKVFilesIn(directory: directory)
    
    try mkvFiles.forEach { fileURL in
        if operation == .remove {
            if option == .all {
                try MKVMerge.shared.removeAllTracksFrom(file: fileURL, type: trackType, option: option)
            }
            else {
                try MKVMerge.shared.removeTrackFrom(file: fileURL, type: trackType, option: option, language: trackLanguage, trackID: trackID)
            }
        }
        else if operation == .modify {
            try MKVMerge.shared.modifyTrackNameIn(file: fileURL,
                                                  type: trackType,
                                                  language: trackLanguage,
                                                  trackID: trackID,
                                                  trackName: trackName ?? "")
        }
    }

    print("Done.")
} catch let error as NSFMKVError {
    print(error)
}












