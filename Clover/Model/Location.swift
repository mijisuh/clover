//
//  Location.swift
//  Clover
//
//  Created by MIJI SUH on 2021/12/03.
//

import Foundation

// 사용자의 현재 위치값을 받아오기 위해 정의한다.
class Location {
    
    static var sharedInstance = Location()
    var longitude: Double!
    var latitude: Double!
    
}
