//
//  AllOOTDDetailViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/12/02.
//

import UIKit
import Alamofire
import SwiftyJSON

class AllOOTDDetailViewController: UIViewController {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var ootdImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var nicknameLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likesBtn: UIButton!
    @IBOutlet weak var descLbl: UILabel!
    
    var ootds: [OOTDModel.Data]?
    var nicknames: [String]?
    var images: [String]?
    var likedOOTD: [Int]?
    var idx: Int?
    var userInfo = UserDefaults.standard
    var azBlobStorageProfile = AZBlobStorage(container: "profile")
    var azBlobStorageOOTD = AZBlobStorage(container: "ootd")
    
    var allOOTDVC:AllOOTDViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        guard let ootds = ootds,
              let images = images,
              let nicknames = nicknames,
              let idx = idx
        else { return }
        
        azBlobStorageOOTD.downloadImage(filename: ootds[idx].imageFilename) { data in
            if let data = data {
                self.ootdImageView.image = UIImage(data: data)
            }
        }
        
        let profileImage = images[idx]
        if profileImage != "-" {
            azBlobStorageProfile.downloadImage(filename: profileImage) { data in
                if let data = data {
                    self.profileImageView.image = UIImage(data: data)
                }
            }
        }
        nicknameLbl.text = nicknames[idx]
        likesLbl.text = "\(ootds[idx].likesNums)"
        descLbl.text = "\"\(ootds[idx].desc)\""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outerView.clipsToBounds = false
        outerView.layer.masksToBounds = false
        outerView.layer.shadowOpacity = 0.3
        outerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        outerView.layer.shadowRadius = 3
        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 20).cgPath
        
        innerView.clipsToBounds = true
        innerView.layer.masksToBounds = true
        innerView.layer.cornerRadius = 10
        innerView.layer.borderWidth = 0.3
        
        outerView.addSubview(innerView)
        
        guard let ootds = ootds,
              let likedOOTD = likedOOTD,
              let idx = idx
        else { return }
        
        // 해당 코디 좋아요 여부 확인해서 좋아요 버튼 설정 초기화
        let ootdId = ootds[idx].ootdId
        
        if likedOOTD.contains(ootdId) {
            likesBtn.isSelected = true
            likesBtn.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        } else {
            likesBtn.isSelected = false
            likesBtn.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
    }
    
    @IBAction func actBack(_ sender: Any) {
        self.allOOTDVC?.viewWillAppear(true)
        self.dismiss(animated: true)
    }
    
    @IBAction func clickLikes(_ sender: Any) {
        guard let ootds = ootds,
              let idx = idx
        else { return }
        
        let ootdId = ootds[idx].ootdId
        
        if likesBtn.isSelected {
            // 좋아요 취소 + 해당 코디의 likes 변경
            cancelLikedOOTD(ootdId: ootdId)
            likesBtn.isSelected = false
            likesBtn.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        } else {
            // 좋아요 등록 + 해당 코디의 likes 변경
            setLikedOOTD(ootdId: ootdId)
            likesBtn.isSelected = true
            likesBtn.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        }
    }
    
    func getAllOOTD() {
        let strURL = "\(AZWEBAPP_URL)/ootd/all/"
        
        callAPI(strURL: strURL, method: .get) { value in
            let json = JSON(value).description
            let decoder = JSONDecoder()
            
            guard let data = json.data(using: .utf8),
                  let ootdInfo = try? decoder.decode(OOTDModel.OOTD.self, from: data)
            else { return }
            
            self.ootds = ootdInfo.data
            self.nicknames = ootdInfo.nicknames
            
            DispatchQueue.main.async {
                self.viewWillAppear(true)
            }
        }
    }
    
    func setLikedOOTD(ootdId: Int) {
        guard let accountId = userInfo.string(forKey: "accountId") else { return }
        let strURL = "\(AZWEBAPP_URL)/likes/"
        
        let params:Parameters = [
            "account_id": accountId,
            "ootd_id": ootdId
        ]
        
        callAPI(strURL: strURL, method: .post, parameters: params) { value in
            let json = JSON(value)
            guard let ootdIds = json["ootdIds"].arrayObject as? [Int]
            else { return }
            
            self.likedOOTD = ootdIds
            
            self.getAllOOTD()
        }
    }
    
    func cancelLikedOOTD(ootdId: Int) {
        guard let accountId = userInfo.string(forKey: "accountId") else { return }
        let strURL = "\(AZWEBAPP_URL)/likes/\(accountId)/\(ootdId)"
        
        callAPI(strURL: strURL, method: .delete) { value in
            let json = JSON(value)
            
            guard let ootdIds = json["ootdIds"].arrayObject as? [Int] else { return }
            
            self.likedOOTD = ootdIds
            
            self.getAllOOTD()
        }
    }
    
}
