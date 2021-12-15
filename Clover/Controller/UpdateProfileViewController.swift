//
//  UpdateProfileViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/28.
//

import UIKit
import DLRadioButton
import Alamofire
import SwiftyJSON

class UpdateProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var snsField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nicknameField: UITextField!{ didSet { nicknameField.delegate = self } }
    @IBOutlet weak var birthdayField: UITextField!{ didSet { birthdayField.delegate = self } }
    
    @IBOutlet weak var femaleBtn: DLRadioButton!
    @IBOutlet weak var maleBtn: DLRadioButton!
    @IBOutlet weak var etcBtn: DLRadioButton!
    
    var mypageVC:MypageViewController?
    var userInfo = UserDefaults.standard
    var gender:String?
    var image_filename = ""
    var isImageSelected = false
    var prevImage = ""
    let picker = UIImagePickerController()
    let azBlobStorage = AZBlobStorage(container: "profile")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let profileImage = userInfo.string(forKey: "profileImage"), profileImage != "-" {
            prevImage = profileImage
            
            azBlobStorage.downloadImage(filename: profileImage) { data in
                if let data = data {
                    self.profileImageView.image = UIImage(data: data)
                }
            }
        }
        
        // 이미지 뷰 클릭 시 동작
        let event = UITapGestureRecognizer(target: self, action: #selector(UpdateProfileViewController.uploadProfileImage))
        profileImageView.addGestureRecognizer(event)
        
        picker.delegate = self
        
        snsField.addUnderLine()
        emailField.addUnderLine()
        nicknameField.addUnderLine()
        birthdayField.addUnderLine()
        
        snsField.text = userInfo.string(forKey: "platformType")
        emailField.text = userInfo.string(forKey: "email")
        nicknameField.text = userInfo.string(forKey: "nickname")
        birthdayField.text = userInfo.string(forKey: "birthday")
        
        gender = userInfo.string(forKey: "gender")
        
        switch(gender) {
        case "female":
            femaleBtn.isSelected = true
        case "male":
            maleBtn.isSelected = true
        default:
            etcBtn.isSelected = true
        }
    }
    
    @objc func uploadProfileImage() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "사진 촬영하기", style: .default) { _ in
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true)
        }
        
        let action2 = UIAlertAction(title: "포토 라이브러리에서 사진 가져오기", style: .default) { _ in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true)
        }
        
        let action3 = UIAlertAction(title: "사진 앨범에서 사진 가져오기", style: .default) { _ in
            self.picker.sourceType = .savedPhotosAlbum
            self.present(self.picker, animated: true)
        }
        
        let action4 = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(action4)
        
        present(alert, animated: true)
    }
    
    @IBAction func selectFemale(_ sender: Any) {
        gender = "female"
    }
    
    @IBAction func selectMale(_ sender: Any) {
        gender = "male"
    }
    
    @IBAction func selectEtc(_ sender: Any) {
        gender = "etc"
    }
    
    @IBAction func actBack(_ sender: Any) {
        self.mypageVC?.viewWillAppear(true)
        self.dismiss(animated: true)
    }
    
    @IBAction func updateProfile(_ sender: Any) {
        // 스토리지에 사진 삭제 및 저장
        if isImageSelected {
            if prevImage != "" {
                azBlobStorage.deleteImage(filename: prevImage)
            }
            
            guard let image = profileImageView.image else { return }
            let rotatedImage = rotateImage(image: image)
            
            if let data = rotatedImage?.pngData() { // 회전된 데이터
                image_filename = azBlobStorage.uploadImage(data: data)
            }
        }
        
        guard let accountId = userInfo.string(forKey: "accountId"),
              let platformType = userInfo.string(forKey: "platformType"),
              let gender = gender
        else { return }
        
        if let nickname = nicknameField.text,
           let birthday = birthdayField.text {
            let strURL = "\(AZWEBAPP_URL)/account/update/\(accountId)"
            var params:Parameters = [
                "platform_type":platformType,
                "nickname":nickname,
                "birthday":birthday,
                "gender":gender
            ]
            
            if isImageSelected {
                params["profile_image"] = image_filename
            }
            
            self.callAPI(strURL: strURL, method: .put, parameters: params) { value in
                self.userInfo.setValue(nickname, forKey: "nickname")
                self.userInfo.setValue(birthday, forKey: "birthday")
                self.userInfo.setValue(gender, forKey: "gender")
                self.userInfo.setValue(self.image_filename, forKey: "profileImage")
                
                self.showResult(title: "프로필 수정이 완료되었습니다.", message: "")
            }
            
        } else {
            self.showResult(title: "빈 항목이 존재합니다.", message: "모든 항목을 기입해주세요.")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension UpdateProfileViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 이미지 정보가 info로 들어옴
        guard let image = info[.originalImage] as? UIImage else { return } // Any 타입에서 형변환
        
        profileImageView?.image = image
        isImageSelected = true
        
        dismiss(animated: true) // present의 반대
    }
    
}
