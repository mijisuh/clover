//
//  MypageViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/27.
//

import UIKit
import Alamofire
import SwiftyJSON

class MypageViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLbl: UILabel!
    
    let userInfo = UserDefaults.standard
    let azBlobStorage = AZBlobStorage(container: "profile")
    
    override func viewWillAppear(_ animated: Bool) {
        let nickname = userInfo.string(forKey: "nickname")
        
        if let profileImage = userInfo.string(forKey: "profileImage"), profileImage != "-" {
            azBlobStorage.downloadImage(filename: profileImage) { data in
                if let data = data {
                    self.profileImageView.image = UIImage(data: data)
                }
            }
        }
        
        self.nicknameLbl.text = nickname
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func updateProfile(_ sender: Any) {
        if let updateProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "update_profile_vc") as? UpdateProfileViewController {
            
            updateProfileVC.mypageVC = self
            updateProfileVC.modalPresentationStyle = .fullScreen
            present(updateProfileVC, animated: true)
        }
    }
    
    @IBAction func signout(_ sender: Any) {
        let alert = UIAlertController(title: "로그아웃 하시겠습니까?", message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "확인", style: .default) { alert in
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                UserDefaults.standard.removeObject(forKey: key.description)
            }
            
            // UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        
        let action2 = UIAlertAction(title: "취소", style: .destructive)
        
        alert.addAction(action1)
        alert.addAction(action2)
        
        self.present(alert, animated: true)
    }

}
