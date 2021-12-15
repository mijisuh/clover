//
//  UploadClothesViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/29.
//

import UIKit
import iOSDropDown
import Alamofire
import SwiftyJSON

class UploadClothesViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var categoryDropDown: DropDown!
    @IBOutlet weak var clothesImageView: UIImageView!
    @IBOutlet weak var descField: UITextField!{ didSet { descField.delegate = self } }
    
    let categories = UserDefaults.standard.array(forKey: "categories")
    let picker = UIImagePickerController()
    let azBlobStorage = AZBlobStorage(container: "clothes")
    var image_filename:String?
    var isImageSelected = false
    
    var closetVC:ClosetViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let categories = categories as? [String] else { return }
        
        categoryDropDown.optionArray = categories
        
        // 이미지 뷰 클릭 시 동작
        let event = UITapGestureRecognizer(target: self, action: #selector(UploadClothesViewController.uploadClothes))
        clothesImageView.addGestureRecognizer(event)
        
        picker.delegate = self
    }
    
    @IBAction func actBack(_ sender: Any) {
        self.closetVC?.viewWillAppear(true)
        self.dismiss(animated: true)
    }
    
    @objc func uploadClothes() {
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
    
    @IBAction func saveClothes(_ sender: Any) {
        // 스토리지에 사진 저장
        if isImageSelected {
            guard let image = clothesImageView.image else { return }
            let rotatedImage = rotateImage(image: image)
            
            if let data = rotatedImage?.pngData() { // 회전된 데이터
                image_filename = azBlobStorage.uploadImage(data: data)
            }
        }
        
        // 클라우드에 저장한 이미지의 파일 이름을 DB에 저장
        guard let categories = categories as? [String],
              let accountId = UserDefaults.standard.string(forKey: "accountId"),
              let categoryIndex = categoryDropDown.selectedIndex,
              let image_filename = image_filename,
              let desc = descField.text
        else { return }
        
        let category = categories[categoryIndex]
        
        let strURL = "\(AZWEBAPP_URL)/clothes/upload/"
        let params:Parameters = [
            "account_id":accountId,
            "category":category,
            "image_filename":image_filename,
            "desc":desc
        ]
        
        callAPI(strURL:strURL, method:.post, parameters: params) { value in
            let json = JSON(value)
            let result = json["success"].boolValue
            
            if result {
                self.showResult(title: "옷 등록", message: "옷 등록 성공")
            } else {
                self.showResult(title: "옷 등록", message: "옷 등록 실패")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension UploadClothesViewController:UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 이미지 정보가 info로 들어옴
        guard let image = info[.originalImage] as? UIImage else { return } // Any 타입에서 형변환
        
        clothesImageView?.image = image
        isImageSelected = true
        
        dismiss(animated: true) // present의 반대
    }
    
}
