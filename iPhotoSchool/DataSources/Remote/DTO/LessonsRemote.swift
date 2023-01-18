//
//  Lessons.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation

struct LessonsListApiModel: Codable {
    let lessons: [LessonApiModel]?
}

struct LessonApiModel: Codable {
    let id: Int?
    let name, description: String?
    let thumbnail: String?
    let videoURL: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, thumbnail
        case videoURL = "video_url"
    }
}
