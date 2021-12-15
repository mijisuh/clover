//
//  Extension.swift
//  Clover
//
//  Created by MIJI SUH on 2021/12/03.
//

import Foundation
import Alamofire
import SwiftyJSON

// 각종 유틸 extension을 정의하는 부분.
// 반올림을 하거나, 날짜 형식으로 바꾸거나 하는 등을 할 수 있다.

extension Double {
    func rounded(toPlaces places:Int)->Double{
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Date {
    func dayOfTheWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
}

extension CurrentWeather {
    func callAPI(strURL:String, handler:@escaping  (Any)->()) {
        let alamo = AF.request(strURL)
        alamo.responseJSON { response in
            switch response.result {
            case .success(let value):
                handler(value)
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
}

extension HourlyWeather {
    func callAPI(strURL:String, handler:@escaping  (Any)->()) {
        let alamo = AF.request(strURL)
        alamo.responseJSON { response in
            switch response.result {
            case .success(let value):
                handler(value)
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
}
