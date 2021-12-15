//
//  OOTDModel.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/30.
//

import Foundation

final class OOTDModel {
    
    struct OOTD: Codable {
        var success:String
        var data:[Data]
        var nicknames:[String]
        var images:[String]
        
        enum CodingKeys:String, CodingKey { // raw value 타입, 정의해야 하는 프로토콜
            case success
            case data
            case nicknames
            case images
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            success = (try? values.decode(String.self, forKey: .success)) ?? ""
            data = (try? values.decode([Data].self, forKey: .data)) ?? []
            nicknames = (try? values.decode([String].self, forKey: .nicknames)) ?? []
            images = (try? values.decode([String].self, forKey: .images)) ?? []
        }
    }
    
    struct Data: Codable {
        var ootdId: Int
        var imageFilename: String
        var accountId: Int
        var likesNums: Int
        var desc: String
        
        enum CodingKeys:String, CodingKey { // raw value 타입, 정의해야 하는 프로토콜
            case ootdId = "ootd_id"
            case imageFilename = "image_filename"
            case accountId = "account_id"
            case likesNums = "likes_nums"
            case desc
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            ootdId = (try? values.decode(Int.self, forKey: .ootdId)) ?? -1
            imageFilename = (try? values.decode(String.self, forKey: .imageFilename)) ?? ""
            accountId = (try? values.decode(Int.self, forKey: .accountId)) ?? -1
            likesNums = (try? values.decode(Int.self, forKey: .likesNums)) ?? 0
            desc = (try? values.decode(String.self, forKey: .desc)) ?? ""
        }
    }
    
}
