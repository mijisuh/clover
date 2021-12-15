//
//  SignupViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/26.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    // 사용자 입력
    @IBOutlet weak var emailField: UITextField!{ didSet { emailField.delegate = self } }
    @IBOutlet weak var passwordField: UITextField!{ didSet { passwordField.delegate = self } }
    @IBOutlet weak var passwordCheckField: UITextField!{ didSet { passwordCheckField.delegate = self } }
    @IBOutlet weak var nicknameField: UITextField!{ didSet { nicknameField.delegate = self } }
    @IBOutlet weak var birthdayField: UITextField!{ didSet { birthdayField.delegate = self } }
    
    var accountModel = AccountModel()
    var gender = "female"
    var requiredFields = [UITextField]()
    var isExistingEmail = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requiredFields = [emailField, passwordField, passwordCheckField, nicknameField, birthdayField]
        
        for field in requiredFields {
            field.addUnderLine()
        }
    }
    
    @IBAction func actBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func selectFemale(_ sender: Any) {
        gender = "female"
    }
    @IBAction func selectMale(_ sender: Any) {
        gender = "male"
    }
    @IBAction func selectEct(_ sender: Any) {
        gender = "etc"
    }
    
    @IBAction func checkEmail(_ sender: Any) {
        guard let email = emailField.text, !email.isEmpty else {
            showResult(title: "이메일을 입력해주세요.", message: "")
            return
        }
        
        let strURL = "\(AZWEBAPP_URL)/signup/check/"
        let params:Parameters = [
            "email":email
        ]
        
        callAPI(strURL:strURL, method:.post, parameters: params) { value in
            let json = JSON(value)
            let exist = json["exist"].boolValue
            
            if exist {
                self.showResult(title: "이미 존재하는 이메일", message: "\(email)은 이미 존재하는 이메일입니다.")
                self.emailField.text = ""
            } else {
                self.isExistingEmail = false
                self.showResult(title: "사용 가능한 이메일", message: "\(email)은 사용 가능한 이메일입니다.")
            }
        }
        
    }
    
    @IBAction func signup(_ sender: Any) {
        guard let email = emailField.text else { return }
        guard let password = passwordField.text else { return }
        guard let passwordCheck = passwordCheckField.text else { return }
        guard let nickname = nicknameField.text else { return }
        guard let birthday = birthdayField.text else { return }
        
        var isAllFilled = true
        var isPasswordSame = true
        
        if !accountModel.isValidEmail(id: email) {
            shakeTextField(textField: emailField)
            emailField.attributedPlaceholder = NSAttributedString(string: "이메일 형식을 확인해 주세요.", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
        }
        
        if !accountModel.isValidPassword(pwd: password) {
            shakeTextField(textField: passwordField)
            passwordField.attributedPlaceholder = NSAttributedString(string: "영문, 숫자 포함 6~16자", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
        }
        
        if password != passwordCheck {
            passwordAlert(title: "비밀번호가 일치하지 않습니다.")
            shakeTextField(textField: passwordCheckField)
            isPasswordSame = false
        }
        
        for field in requiredFields {
            if !isFilled(field) {
                signUpAlert(field)
                isAllFilled = false
                break
            }
        }
        
        if isAllFilled, isExistingEmail {
            showResult(title: "이메일 중복 확인이 필요합니다.", message: "")
        }
        
        if isAllFilled, isPasswordSame, !isExistingEmail {
            // api 요청
            let strURL = "\(AZWEBAPP_URL)/signup/"
            let params:Parameters = [
                "platform_type":"none",
                "email":email,
                "password":password,
                "nickname":nickname,
                "birthday":birthday,
                "gender":gender,
                "profile_image":"-"
            ]
            
            callAPI(strURL:strURL, method:.post, parameters: params) { value in
                let json = JSON(value)
                let nickname = json["data"]["nickname"].stringValue
                
                // 화면 이동
                if let completeSignupVC = self.storyboard?.instantiateViewController(withIdentifier: "complete_signup_vc") as? CompleteSignupViewController {
                    
                    // 데이터 전달
                    completeSignupVC.nickname = nickname
                    
                    completeSignupVC.modalPresentationStyle = .fullScreen
                    self.present(completeSignupVC, animated: true)
                }
            }
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension SignupViewController {
    // TextField 흔들기 애니메이션
    func shakeTextField(textField: UITextField) -> Void{
        textField.text = ""
        UIView.animate(withDuration: 0.2, animations: {
            textField.frame.origin.x -= 10
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                textField.frame.origin.x += 20
             }, completion: { _ in
                 UIView.animate(withDuration: 0.2, animations: {
                    textField.frame.origin.x -= 10
                })
            })
        })
    }
    
    func signUpAlert(_ field: UITextField) {
        DispatchQueue.main.async {
            var title = ""
            switch field {
            case self.emailField:
                title = "아이디를 입력해주세요."
            case self.passwordField:
                title = "비밀번호를 입력해주세요."
            case self.passwordCheckField:
                title = "비밀번호를 확인해주세요."
            case self.nicknameField:
                title = "닉네임을 입력해주세요."
            case self.birthdayField:
                title = "생년월일을 입력해주세요."
            default:
                title = "Error"
            }
            
            self.shakeTextField(textField: field)
            
            let controller = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "닫기", style: .cancel) { (action) in
                
            }
            
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func passwordAlert(title: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "닫기", style: .cancel) { (action) in
            }
            
            controller.addAction(cancelAction)
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func isFilled(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else {
            return false
        }
        return true
    }
}
