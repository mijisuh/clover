//
//  AllOOTDCell.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/30.
//

import UIKit

class AllOOTDCell: UICollectionViewCell {
    
    @IBOutlet weak var ootdView: UIView!
    @IBOutlet weak var ootdImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likesBtn: UIButton!
    
    var likes: (() -> ()) = {}
    
    @IBAction func clickLikes(_ sender: UIButton) {
       //Call your closure here
        likes()
        if likesBtn.isSelected {
            likesBtn.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        } else {
            likesBtn.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
    }
    
    func setupLayout(backView: UIView) {
        backView.layer.masksToBounds = true
        backView.layer.cornerRadius = 10
        backView.layer.borderWidth = 0.1
        
        layer.masksToBounds = false
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 3
    }
    
}
