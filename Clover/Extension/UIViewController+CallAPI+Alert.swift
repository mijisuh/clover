//
//  UIViewController+CallAPI.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/27.
//

import UIKit
import Alamofire

extension UIViewController { // UIViewController 상속 받은 모든 곳에서 사용 가능

    func callAPI(strURL:String, method:HTTPMethod, parameters:Parameters?=nil, headers:HTTPHeaders?=nil, handler:@escaping  (Any)->()) {
        let alamo = AF.request(strURL, method:method, parameters: parameters)
        alamo.responseJSON { response in
            switch response.result {
            case .success(let value):
                handler(value)
            case .failure(let error):
                print(error.errorDescription!)
            }
        }
    }
    
    func callAPI(strURL:String, handler:@escaping  (Any)->()) {
        let alamo = AF.request(strURL)
        alamo.responseJSON { response in
            switch response.result {
            case .success(let value):
                handler(value)
            case .failure(let error):
                print(error.errorDescription!)
            }
        }
    }
    
    func showResult(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "확인", style: .default)
        alert.addAction(action1)
        
        self.present(alert, animated: true)
    }
    
    // 이미지 회전
    func rotateImage(image:UIImage)->UIImage? {
        if(image.imageOrientation == .up) {// orientation: 방향
            return image
        }
        
        // 'up'이 아니면 다시 그려서 캡쳐해서 반환
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size)) // 좌표 설정 -> 원점
        
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return copy
    }
    
}
