//
//  UploadOOTDDetailViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/12/02.
//

import UIKit
import Alamofire
import SwiftyJSON

class UploadOOTDDetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ootdDesc: UITextField!{ didSet { ootdDesc.delegate = self } }
    @IBOutlet weak var ootdImageView: UIImageView!
    
    var ootdImage:UIImage?
    var date:String?
    var image_filename:String?
    var azBlobStorage = AZBlobStorage(container: "ootd")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let ootdImage = ootdImage {
            ootdImageView.image = ootdImage
        }
    }

    @IBAction func actBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func uploadOOTD(_ sender: Any) {
        // 스토리지에 사진 저장
        guard let image = ootdImage else { return }
        let rotatedImage = rotateImage(image: image)
        
        if let data = rotatedImage?.pngData() { // 회전된 데이터
            image_filename = azBlobStorage.uploadImage(data: data)
        }
        
        guard let date = self.date,
              let accountId = UserDefaults.standard.string(forKey: "accountId"),
              let image_filename = self.image_filename,
              let desc = ootdDesc.text
        else { return }
        
        let strURL = "\(AZWEBAPP_URL)/ootd/upload/"
        let params:Parameters = [
            "account_id":accountId,
            "date":date,
            "image_filename":image_filename,
            "desc":desc
        ]
        
        callAPI(strURL:strURL, method:.post, parameters: params) { value in
            let json = JSON(value)
            let result = json["success"].boolValue
            
            if result {
                self.showResult(title: "코디 등록", message: "코디 등록 성공")
            } else {
                self.showResult(title: "코디 등록", message: "코디 등록 실패")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
