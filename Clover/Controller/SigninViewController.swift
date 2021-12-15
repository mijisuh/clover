//
//  SigninViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/27.
//

import UIKit
import Alamofire
import SwiftyJSON
import FBSDKLoginKit

class SigninViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!{ didSet { emailField.delegate = self } }
    @IBOutlet weak var passwordField: UITextField!{ didSet { passwordField.delegate = self } }
    
    let azBlobStorage = AZBlobStorage(container: "profile")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
    }
    
    @IBAction func signin(_ sender: Any) {
        guard let email = emailField.text,
              let password = passwordField.text
        else { return }
        
        let strURL = "\(AZWEBAPP_URL)/signin/"
        let params:Parameters = [
            "email":email,
            "password":password
        ]
        
        callAPI(strURL:strURL, method:.post, parameters: params) { value in
            let json = JSON(value)
            let success = json["success"].boolValue
            let accountId = json["data"][0]["account_id"].intValue
            
            if success {
                // 화면 이동
                if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "main_vc") as? TabBarController {
                    UserDefaults.standard.setValue(accountId, forKey: "accountId")
                    
                    mainVC.modalPresentationStyle = .fullScreen
                    self.present(mainVC, animated: true)
                }
            } else {
                self.showResult(title: "잘못된 로그인 정보", message: "이메일과 비밀번호를 다시 입력해주세요.")
                self.emailField.text = ""
                self.passwordField.text = ""
            }
        }
    }
    
    @IBAction func signinWithFB(_ sender: Any) {
        LoginManager().logIn(permissions: ["public_profile", "email", "user_birthday", "user_gender"], from: self, handler: { (result, error) in
            guard let result = result, error == nil && !result.isCancelled else {
                print("error: \(error)")
                // 로그인 취소/에러
                return
            }

            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture, birthday, gender"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error != nil) { // 로그인 에러
                    return
                }
                
                guard let facebook = result as? [String: AnyObject] else { return }

                let token = facebook["id"] as? String
                
                let strURL = "\(AZWEBAPP_URL)/signin/fb/\(token!)"
                self.callAPI(strURL: strURL, method: .get) { value in
                    let json = JSON(value)
                    let exist = json["exist"].boolValue
                    
                    if !exist {
                        let name = facebook["name"] as? String
                        let email = facebook["email"] as? String
                        let largeProfile = "https://graph.facebook.com/\((token ?? ""))/picture?type=large"
                        let gender = facebook["gender"] as? String
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyMMdd"
                        
                        var birthdayDate: Date?
                        if let birthday = facebook["birthday"] as? String, birthday != "" {
                            birthdayDate = dateFormatter.date(from: birthday)
                        }
                        
                        // 프로필 사진 Azure blob 스토리지 저장
                        // url -> data
                        var profileImage = ""
                        if let profileImageURL = URL(string: largeProfile),
                           let data = try? Data(contentsOf: profileImageURL) {
                            profileImage = self.azBlobStorage.uploadImage(data: data)
                        }
                        
                        let strURL = "\(AZWEBAPP_URL)/signin/fb/"
                        let params:Parameters = [
                            "platform_type":"fb",
                            "user_id":token!,
                            "email":email!,
                            "nickname":name!,
                            "birthday":"",
                            "gender":"etc",
                            "profile_image":profileImage
                        ]
                        
                        self.callAPI(strURL:strURL, method:.post, parameters: params) { value in
                            let json = JSON(value)
                            let accountId = json["data"]["account_id"].intValue
                            
                            UserDefaults.standard.setValue(accountId, forKey: "accountId")
                            
                            // 화면 이동
                            if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "main_vc") as? TabBarController {
                                mainVC.modalPresentationStyle = .fullScreen
                                self.present(mainVC, animated: true)
                            }
                        }
                    } else {
                        let accountId = json["account_id"].intValue
                        
                        UserDefaults.standard.setValue(accountId, forKey: "accountId")
                        
                        // 화면 이동
                        if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "main_vc") as? TabBarController {
                            mainVC.modalPresentationStyle = .fullScreen
                            self.present(mainVC, animated: true)
                        }
                    }
                }
            })
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
