//
//  TabBarController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/25.
//

import UIKit
import Alamofire
import SwiftyJSON

class TabBarController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let accountId = UserDefaults.standard.integer(forKey: "accountId")
        
        let strURL = "\(AZWEBAPP_URL)/account/\(accountId)"
        
        callAPI(strURL:strURL, method:.get) { value in
            let json = JSON(value)
            let data = json["data"].description
            
            let decoder = JSONDecoder()
            
            guard let data = data.data(using: .utf8) else { return }
            if let account = try? decoder.decode(AccountModel.Account.self, from: data) {
                UserDefaults.standard.setValue(account.platformType, forKey: "platformType")
                UserDefaults.standard.setValue(account.email, forKey: "email")
                UserDefaults.standard.setValue(account.nickname, forKey: "nickname")
                UserDefaults.standard.setValue(account.birthday, forKey: "birthday")
                UserDefaults.standard.setValue(account.gender, forKey: "gender")
                UserDefaults.standard.setValue(account.profileImage, forKey: "profileImage")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndex = 2
    }
    
}
