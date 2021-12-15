//
//  LikesModel.swift
//  Clover
//
//  Created by MIJI SUH on 2021/12/02.
//

import Foundation

final class LikesModel {
    
    struct Likes: Codable {
        var success: String
        var ootds:[OOTD]
        var ootdIds:[Int]
        var nicknames:[String]
        var images:[String]
        
        enum CodingKeys:String, CodingKey {
            case success
            case ootds
            case ootdIds
            case nicknames
            case images
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            success = (try? values.decode(String.self, forKey: .success)) ?? ""
            ootds = (try? values.decode([OOTD].self, forKey: .ootds)) ?? []
            ootdIds = (try? values.decode([Int].self, forKey: .ootdIds)) ?? []
            nicknames = (try? values.decode([String].self, forKey: .nicknames)) ?? []
            images = (try? values.decode([String].self, forKey: .images)) ?? []
        }
    }
    
    struct OOTD: Codable {
        var ootdId: Int
        var imageFilename: String
        var accountId: Int
        var likesNums: Int
        
        enum CodingKeys:String, CodingKey { // raw value 타입, 정의해야 하는 프로토콜
            case ootdId = "ootd_id"
            case imageFilename = "image_filename"
            case accountId = "account_id"
            case likesNums = "likes_nums"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            ootdId = (try? values.decode(Int.self, forKey: .ootdId)) ?? -1
            imageFilename = (try? values.decode(String.self, forKey: .imageFilename)) ?? ""
            accountId = (try? values.decode(Int.self, forKey: .accountId)) ?? -1
            likesNums = (try? values.decode(Int.self, forKey: .likesNums)) ?? 0
        }
    }
    
}
