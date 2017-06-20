//
//  TextNote.swift
//  NotesForTheVisuallyChallenged
//
//  Created by 傅信穎 on 2017/6/5.
//  Copyright © 2017年 MAP. All rights reserved.
//

import Foundation
import ObjectMapper


struct TextNote : Mappable{
    
    
//    default tags is an array containing a Untitled_dateString only.
    
//    fileName is constructed by tags and seperated by "_",i.e.,tag1_tag2_tag3
//    If tag3 is empty,then tag1_tag2
    
    
    var tags : [String] = TextNote.defaultTags()

    var content: String = ""
    
    var date = TextNote.getDateAndTime()
    
    var fileURL: URL {
        return TextNote.fileURL(of: self.tags)
    }
    
    
    mutating func save() throws {
        
        if let noteInJSON = self.toJSONString(prettyPrint: true){
            try noteInJSON.write(to: self.fileURL, atomically: true, encoding: .utf8)
        }
    }
    
}

// MARK: - Storage methods

extension TextNote {
    
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
  
     
//    default tags are ["Untitled_currentDate"]
//    however,the currentDate string here is not the same with the date property of TextNote object
//    and this is a bug
    static func defaultTags() -> [String] {
        var tags  = [String]()
        let date = Date()
        let dateString = TextNote.noteDateFormatter.string(from: date)
        tags.append("Untitled_" + dateString)
        return tags
    }

    
    static func fileName(of tags: [String]) -> String {
        var fileName = tags.first!
        for index in 1 ..< tags.count {
            fileName = fileName + "_" + tags[index]
        }
        return "\(fileName).json"
    }

    static func getDateAndTime() -> String{
        return  TextNote.noteDateFormatter.string(from: Date())
    }
    
    private static let noteDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日HH點mm分ss秒"
        return dateFormatter
    }()
    
    // MARK: I/O
    
    static func getTagsOfSavedNotes() -> [[String]] {
        var result = [[String]]()
        guard let noteURLs = try?
            FileManager.default.contentsOfDirectory(at: TextNote.storageURL,
                                                    includingPropertiesForKeys: nil) else { return [] }
        
        for noteURL in noteURLs {
            guard noteURL.pathExtension == "json" else { continue }
            result.append(self.tags(from: noteURL))
        }
        return result
    }
    
    // Will it cause error when convert JSON string to TextNote?
    static func open(tags: [String]) throws -> TextNote? {
        let stringOfNoteInJSON = try String(contentsOf: self.fileURL(of: tags), encoding: .utf8)
        return TextNote(JSONString: stringOfNoteInJSON)!
    }
    
    static func remove(tags: [String]) throws {
        try FileManager.default.removeItem(at: self.fileURL(of: tags))
    }
    
}
extension Notification.Name {
    static let TextNoteDidUpdate = Notification.Name("TextNoteDidUpdate")
}
extension TextNote {
    fileprivate static func postDidUpdateNotification() {
        let notification = Notification(name: .TextNoteDidUpdate)
        NotificationQueue.default.enqueue(notification, postingStyle: .asap)
    }
}


// MARK: - ObjectMapper protocol

extension TextNote {
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        tags <- map["tags"]
        content <- map["content"]
        date <- map["date"]
        
    }
}
