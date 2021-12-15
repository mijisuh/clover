//
//  Extras.swift
//  Clover
//
//  Created by MIJI SUH on 2021/12/03.
//

import Foundation

//let API_URL = "https://api.openweathermap.org/data/2.5/weather?lat=\(Location.sharedInstance.latitude!)&lon=\(Location.sharedInstance.longitude!)&APPID=a853ba1f86e00f42fe254fa5b87956f6"

//let FORECAST_API_URL = "https://api.openweathermap.org/data/2.5/onecall?lat=\(Location.sharedInstance.latitude!)&lon=\(Location.sharedInstance.longitude!)&appid=a853ba1f86e00f42fe254fa5b87956f6"

// 날씨 API URL - 남부여성발전센터 위치 설정
let API_URL = "https://api.openweathermap.org/data/2.5/weather?lon=126.9061060613701&lat=37.46358925614127&APPID=a853ba1f86e00f42fe254fa5b87956f6"

let FORECAST_API_URL = "https://api.openweathermap.org/data/2.5/onecall?lon=126.9061060613701&lat=37.46358925614127&appid=a853ba1f86e00f42fe254fa5b87956f6"

typealias DownloadComplete = () -> ()

// AZ Blob Storage
let AZSTORAGE_CONNECTION_STRING = "DefaultEndpointsProtocol=https;AccountName=cloverazblobstorage;AccountKey=fKsSWnuFglYZS/r01tJ6IBH7sbbFWS3qMIJMKOMK4OzL93du0vcApjx/TkDu9METrU7j+hi836wxs5h53Q+I7A==;EndpointSuffix=core.windows.net"

let AZWEBAPP_URL = "https://clover-patmat.azurewebsites.net/clover"
