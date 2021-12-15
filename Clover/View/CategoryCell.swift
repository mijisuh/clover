//
//  CategoryCell.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/29.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryLbl: UILabel!
    
    func setupLayout() {
        categoryLbl.font = UIFont(name: "Pretendard-Medium", size: 13)
    }
    
    func selectCell() {
        categoryLbl.font = UIFont(name: "Pretendard-Bold", size: 13)
    }
}
