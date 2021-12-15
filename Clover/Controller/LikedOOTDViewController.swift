//
//  LikedOOTDViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/12/02.
//

import UIKit
import Alamofire
import SwiftyJSON

class LikedOOTDViewController: UIViewController {

    @IBOutlet weak var likesCollectionView: UICollectionView!
    
    var userInfo = UserDefaults.standard
    var ootds:[LikesModel.OOTD]?
    var likedOOTD:[Int] = []
    var nicknames:[String] = []
    var images:[String] = []
    var azBlobStorageProfile = AZBlobStorage(container: "profile")
    var azBlobStorageOOTD = AZBlobStorage(container: "ootd")
    
    
    override func viewWillAppear(_ animated: Bool) {
        getLikesOOTDByAccountId()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func getLikesOOTDByAccountId() {
        guard let accountId = userInfo.string(forKey: "accountId") else { return }
        let strURL = "\(AZWEBAPP_URL)/likes/\(accountId)"
        
        callAPI(strURL: strURL, method: .get) { value in
            let json = JSON(value).description
            let decoder = JSONDecoder()
            
            guard let data = json.data(using: .utf8),
                  let likesInfo = try? decoder.decode(LikesModel.Likes.self, from: data)
            else { return }
            
            self.ootds = likesInfo.ootds
            self.likedOOTD = likesInfo.ootdIds
            self.nicknames = likesInfo.nicknames
            self.images = likesInfo.images

            DispatchQueue.main.async {
                self.likesCollectionView.reloadData()
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
            
            print("추가: \(self.likedOOTD)")
            
            DispatchQueue.main.async {
                self.viewWillAppear(true)
            }
        }
    }
    
    func cancelLikedOOTD(ootdId: Int) {
        guard let accountId = userInfo.string(forKey: "accountId") else { return }
        let strURL = "\(AZWEBAPP_URL)/likes/\(accountId)/\(ootdId)"
        
        callAPI(strURL: strURL, method: .delete) { value in
            let json = JSON(value)
            
            guard let ootdIds = json["ootdIds"].arrayObject as? [Int] else { return }
            
            self.likedOOTD = ootdIds
            
            print("삭제: \(self.likedOOTD)")
            
            DispatchQueue.main.async {
                self.viewWillAppear(true)
            }
        }
    }

}

extension LikedOOTDViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let ootds = ootds {
            return ootds.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "liked_ootd_cell", for: indexPath) as? AllOOTDCell,
              let ootds = ootds
        else { return UICollectionViewCell() }
        
        cell.setupLayout(backView: cell.ootdView)
        
        let image_filename = ootds[indexPath.row].imageFilename
        
        azBlobStorageOOTD.downloadImage(filename: image_filename) { data in
            if let data = data {
                cell.ootdImageView.image = UIImage(data: data)
            }
        }
        
        let profileImage = images[indexPath.row]
        if profileImage != "-" {
            azBlobStorageProfile.downloadImage(filename: profileImage) { data in
                if let data = data {
                    cell.profileImageView.image = UIImage(data: data)
                }
            }
        }
        
        cell.nicknameLbl.text = nicknames[indexPath.row]
        cell.likesLbl.text = "\(ootds[indexPath.row].likesNums)"
        
        // 해당 코디 좋아요 여부 확인해서 좋아요 버튼 설정 초기화
        if likedOOTD.contains(ootds[indexPath.row].ootdId) {
            cell.likesBtn.isSelected = true
            cell.likesBtn.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        } else {
            cell.likesBtn.isSelected = false
            cell.likesBtn.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
        
        cell.likes = { [unowned self] in
            // 좋아요 DB에 등록
            // 좋아요 DB 등록 여부 확인
            
            if cell.likesBtn.isSelected {
                // 좋아요 취소 + 해당 코디의 likes 변경
                cancelLikedOOTD(ootdId: ootds[indexPath.row].ootdId)
                cell.likesBtn.isSelected = false
            } else {
                // 좋아요 등록 + 해당 코디의 likes 변경
                setLikedOOTD(ootdId: ootds[indexPath.row].ootdId)
                cell.likesBtn.isSelected = true
            }
        }
        
        return cell
    }
    
}
