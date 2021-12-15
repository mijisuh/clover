//
//  CircleImageView.swift
//  Clover
//
//  Created by MIJI SUH on 2021/12/04.
//

import UIKit

class CircularImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
        self.clipsToBounds = true
    }
    
}
