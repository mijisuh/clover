//
//  ClothesModel.swift
//  Clover
//
//  Created by MIJI SUH on 2021/12/01.
//

import Foundation

final class ClothesModel {
    
    struct Clothes: Codable {
        var success: String
        var data:[Data]
    }
    
    struct Data: Codable {
        var clothesId: Int
        var imageFilename: String
        var desc: String
        
        enum CodingKeys:String, CodingKey { // raw value 타입, 정의해야 하는 프로토콜
            case clothesId = "clothes_id"
            case imageFilename = "image_filename"
            case desc
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            clothesId = (try? values.decode(Int.self, forKey: .clothesId)) ?? -1
            imageFilename = (try? values.decode(String.self, forKey: .imageFilename)) ?? ""
            desc = (try? values.decode(String.self, forKey: .desc)) ?? ""
        }
    }
    
}
