//
//  DataFile.swift
//  WebRTC-Demo
//
//  Created by Suraj Kumbhar on 11/01/24.
//  Copyright © 2024 Stas Seldin. All rights reserved.
//

import Foundation


struct Packet: Codable {
    let filetype : String
    let fileSize: Int
    let fileData: String
}

//struct DataFile{
//    let filetype : String
//    let fileSize: Int
//    let fileData: String
//    
//
////    enum CodingKeys: String, CodingKey {
////        case filetype = "filetype"
////        case fileSize = "fileSize"
////        case fileData = "fileData"
////    }
////
////    init(from decoder: Decoder) throws {
////        let values = try decoder.container(keyedBy: CodingKeys.self)
////        filetype = try values.decodeIfPresent(String.self, forKey: .filetype)
////        fileSize = try values.decodeIfPresent(Int.self, forKey: .fileSize)
////        fileData = try values.decodeIfPresent(String.self, forKey: .fileData)
////        
////        
////    }
//}
