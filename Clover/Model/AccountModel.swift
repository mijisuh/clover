//
//  Account.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/27.
//

import Foundation

final class AccountModel {
    
    struct Account: Codable {
        var platformType: String
        var email: String
        var password: String
        var nickname: String
        var birthday: String
        var gender: String
        var profileImage: String
        
        enum CodingKeys:String, CodingKey { // raw value 타입, 정의해야 하는 프로토콜
            case platformType = "platform_type"
            case email
            case password
            case nickname
            case birthday
            case gender
            case profileImage = "profile_image"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            platformType = (try? values.decode(String.self, forKey: .platformType)) ?? ""
            email = (try? values.decode(String.self, forKey: .email)) ?? "" // nil이면 ""로 처리
            password = (try? values.decode(String.self, forKey: .password)) ?? ""
            nickname = (try? values.decode(String.self, forKey: .nickname)) ?? ""
            birthday = (try? values.decode(String.self, forKey: .birthday)) ?? ""
            gender = (try? values.decode(String.self, forKey: .gender)) ?? ""
            profileImage = (try? values.decode(String.self, forKey: .profileImage)) ?? ""
        }
    }
    
    // 아이디 형식 검사
    func isValidEmail(id: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: id)
    }
    
    // 비밀번호 형식 검사
    func isValidPassword(pwd: String) -> Bool {
        let passwordRegEx = "^[a-zA-Z0-9]{6,16}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: pwd)
    }
    
}
