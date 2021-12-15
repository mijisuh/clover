//
//  SigninWithKakaoViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/27.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import Alamofire
import SwiftyJSON

class SigninWithKakaoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.window?.rootViewController = self
    }
    
    @IBAction func signinWithAccount(_ sender: Any) {
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                if let user = user {
                    var scopes = [String]()
                    
                    if (user.kakaoAccount?.emailNeedsAgreement == true) { scopes.append("account_email") }
                    if (user.kakaoAccount?.genderNeedsAgreement == true) { scopes.append("gender") }
                    
                    if scopes.count == 0  { return }
                    
                    //필요한 scope으로 토큰갱신을 한다.
                    UserApi.shared.loginWithKakaoAccount(scopes: scopes) { (_, error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            UserApi.shared.me() { (user, error) in
                                if let error = error {
                                    print(error)
                                }
                                else {
                                    print("me() success.")
                                    
                                    //do something
                                    _ = user
                                }
                                
                            } //UserApi.shared.me()
                        }
                        
                    } //UserApi.shared.loginWithKakaoAccount(scopes:)
                }
            }
        }
        
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if let error = error {
                print(error)
            }
            else {
                print("loginWithKakaoAccount() success.")
                
                //do something
                _ = oauthToken
                self.accountInfo()
            }
        }
    }
    
    @IBAction func actBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func accountInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                let userId = user?.id
                let nickname = user?.kakaoAccount?.profile?.nickname
                let email = user?.kakaoAccount?.email
                let gender = user?.kakaoAccount?.gender
                let profileImage = user?.kakaoAccount?.profile?.profileImageUrl
                
                let strURL = "\(AZWEBAPP_URL)/signin/kakao/"
                var params:Parameters = [
                    "platform_type":"kakao",
                    "user_id":userId!,
                    "nickname":nickname!,
                    "profile_image":profileImage!
                ]
                
                if let email = email,
                   let gender = gender {
                    params["email"] = email
                    params["gender"] = gender
                    print("이메일 \(email) // 성별 \(gender)")
                }
                
                self.callAPI(strURL:strURL, method:.post, parameters: params) { value in
                    let json = JSON(value)
                    // let success = json["success"].boolValue
                    let accountId = json["data"]["account_id"].intValue
                    
                    // 화면 이동
                    if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "main_vc") as? TabBarController {
                        // 회원 정보 UserDefaults 저장
                        for key in UserDefaults.standard.dictionaryRepresentation().keys {
                            UserDefaults.standard.removeObject(forKey: key.description)
                        }
                        
                        UserDefaults.standard.setValue(accountId, forKey: "accountId")
                        
                        mainVC.modalPresentationStyle = .fullScreen
                        self.present(mainVC, animated: true)
                    }
                }
            }
        }
    }
}
