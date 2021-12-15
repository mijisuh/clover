//
//  OOTDCell.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/30.
//

import UIKit

class OOTDCell: UICollectionViewCell {
    
    @IBOutlet weak var ootdView: UIView!
    @IBOutlet weak var ootdImageView:UIImageView!
    
    func setupLayout(backView: UIView) {
        backView.layer.masksToBounds = true
        backView.layer.cornerRadius = 10
        backView.layer.borderWidth = 0.1
        
        layer.masksToBounds = false
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 3
    }
    
    func selectCell(backView: UIView) {
        backView.layer.masksToBounds = true
        backView.layer.cornerRadius = 10
        backView.layer.borderWidth = 2
        backView.layer.borderColor = UIColor.gray.cgColor
        
        layer.masksToBounds = false
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 3
    }
    
}
