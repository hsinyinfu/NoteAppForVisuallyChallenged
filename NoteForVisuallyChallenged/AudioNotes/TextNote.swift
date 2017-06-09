//
//  TextNote.swift
//  NotesForTheVisuallyChallenged
//
//  Created by 傅信穎 on 2017/6/5.
//  Copyright © 2017年 MAP. All rights reserved.
//

import Foundation
import ObjectMapper


struct TextNote{ /*: Mappable*/
    
    var tags : [String] = TextNote.defaultTags()

    var content: String = ""
    
    var fileURL: URL {
        return TextNote.fileURL(of: self.tags)
    }
    
    func save() throws {
        try self.content.write(to: self.fileURL, atomically: true, encoding: .utf8)
    }
    
}

// MARK: - Storage methods

extension TextNote {
    /*
     We use the first tag as the file name of a note.
     */
    
    // MARK: Storage location
    
    static let storageURL: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    static func fileURL(of tags: [String]) -> URL {
        
        return self.storageURL.appendingPathComponent(self.fileName(of: tags))
    }

    
    // MARK: File name
    
    static func tags(from url: URL) -> [String] {
        // Get the file name of the URL without file extension (this is the definition of the "title".)
        return url.deletingPathExtension().lastPathComponent.components(separatedBy: "_")
    }
    
    
    static func defaultTags() -> [String] {
        var tags  = [String]()
        let date = Date()
        let dateString = TextNote.tagDateFormatter.string(from: date)
        tags.append("Untitled_" + dateString)
        return tags
    }

    
    static func fileName(of tags: [String]) -> String {
        var fileName = tags.first!
        for index in 1 ..< tags.count {
            fileName = fileName + "_" + tags[index]
        }
        return "\(fileName).txt"
    }

    
    private static let tagDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        return dateFormatter
    }()
    
    // MARK: I/O
    
    static func tagsOfSavedNotes() -> [[String]] {
        var result = [[String]]()
        guard let noteURLs = try?
            FileManager.default.contentsOfDirectory(at: TextNote.storageURL,
                                                    includingPropertiesForKeys: nil) else { return [] }
        
        for noteURL in noteURLs {
            guard noteURL.pathExtension == "txt" else { continue }
            result.append(self.tags(from: noteURL))
        }
        return result
    }
    
    static func open(tags: [String]) throws -> TextNote {
        let noteContent = try String(contentsOf: self.fileURL(of: tags), encoding: .utf8)
        return TextNote(tags: tags, content: noteContent)
    }
    
    static func remove(tags: [String]) throws {
        try FileManager.default.removeItem(at: self.fileURL(of: tags))
    }
}

    // MARK: ObjectMapper protocol

//// not yet finished
//extension TextNote {
//    init?(map: Map) {}
//    
//    mutating func mapping(map: Map) {
//        tags <- map["tags"]
//        content <- map["content"]
//        
//    }
//}
