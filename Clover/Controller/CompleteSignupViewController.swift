//
//  CompleteSignupViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/27.
//

import UIKit

class CompleteSignupViewController: UIViewController {
    
    @IBOutlet weak var welcomeLbl: UILabel!
    
    var nickname:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let nickname = nickname else { return}

        welcomeLbl.text = "\(nickname) 님 환영합니다!"
    }

}
