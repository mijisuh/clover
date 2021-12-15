//
//  WeatherViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/12/03.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var currentDate: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherType: UILabel!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var uv: UILabel!
    @IBOutlet weak var wind: UILabel!
    
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tipLbl: UILabel!
    
    var locationManager = CLLocationManager()
    
    // Variables
    var currentWeather: CurrentWeather!
    var currentLocation: CLLocation!
    
    // For Hourly Variables
    var hourlyWeather: HourlyWeather!
    var hourlyArray = [HourlyWeather]()
    
    var countFlag: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation() //위치 정보 받아오기 시작
        locationManager.startUpdatingHeading()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentWeather = CurrentWeather()
        
        // core location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        // 차로 이동, 도보로 이동 시 정확도 설정 다르게 가능
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 빠른 속도로 위치가 변화할 때
        // manager.desiredAccuracy = kCLLocationAccuracyKilometer // 느린 속도
        locationManager.requestAlwaysAuthorization() // 사용자에게 허용 받기 alert 띄우기
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthCheck()
        
        if self.countFlag == 0{
            downloadHourlyWeather{
                print("Data Downloaded")
            }
            self.countFlag = 1
        }
    }
    
    // location 동의 여부 체크
    func locationAuthCheck(){
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 On 상태")
            
            // 스마트폰으로부터 위치 정보를 받아온다.
            if let currentLocation = locationManager.location {
                Location.sharedInstance.latitude = currentLocation.coordinate.latitude
                Location.sharedInstance.longitude = currentLocation.coordinate.longitude
                print(currentLocation)
                
                print("위치 정보 확인")
                
                // 위치정보를 모두 받은 뒤에, API data를 다운로드받는다.
                currentWeather.downloadCurrentWeather {
                    self.updateUI()
                    self.getTipByTemp()
                }
            } else {
                locationManager.requestAlwaysAuthorization()
                locationAuthCheck()
            }
        } else { // 유저가 위치정보 기능을 allow하지 않았을 경우, 다시 한번 허가받기
            print("위치 서비스 Off 상태")
            
            locationManager.requestAlwaysAuthorization()
            locationAuthCheck()
        }
    }
    
    // 받아온 데이터들로 업데이트 하는 함수
    func updateUI(){
        cityName.text = currentWeather.cityName
        currentTemp.text = "\(Int(currentWeather.currentTemp))"+"°"
        
        // weather type 한글화하기
        let rawWeather = currentWeather.weatherType
        
        switch(rawWeather) {
        case "Clear":
            weatherType.text = "맑음"
        case "Clouds":
            weatherType.text = "흐림"
        case "Rain":
            weatherType.text = "비"
        case "Thunderstorm":
            weatherType.text = "번개"
        case "Snow":
            weatherType.text = "눈"
        case "Haze", "Mist":
            weatherType.text = "안개"
        default:
            weatherType.text = "-"
        }
        
        currentDate.text = currentWeather.date
        
        let rawHour = (Int)(currentWeather.hour)
        
        if currentWeather.description == "overcast clouds" && rawHour! >= 6 && rawHour! <= 18 {
            weatherImage.image = UIImage(named: "overcast")
        }
        else if currentWeather.description == "overcast clouds"
                    && ( (rawHour! >= 19 && rawHour! <= 23) || (rawHour! >= 0 && rawHour! <= 5)) {
            weatherImage.image = UIImage(named: "overcastMoon")
        }
        else if currentWeather.description == "Clear"
                    && rawHour! >= 6 && rawHour! <= 18 {
            weatherImage.image = UIImage(named: "Clear")
        }
        else if currentWeather.description == "Clear"
                    && ( (rawHour! >= 19 && rawHour! <= 23) || (rawHour! >= 0 && rawHour! <= 5))  {
            weatherImage.image = UIImage(named: "ClearMoon")
        }
        else{
            weatherImage.image = UIImage(named: currentWeather.weatherType)
        }
        
        wind.text = "\(Double(currentWeather.wind))" + "m/s"
        
        // 자외선
        if (currentWeather.uv <= 2){
            uv.text = "낮음" + "(" + "\(Double(currentWeather.uv))" + ")"
        }
        else if (currentWeather.uv <= 5){
            uv.text = "보통" + "(" + "\(Double(currentWeather.uv))" + ")"
        }
        else if (currentWeather.uv <= 7){
            uv.text = "높음" + "(" + "\(Double(currentWeather.uv))" + ")"
        }
        else if (currentWeather.uv <= 10){
            uv.text = "매우 높음" + "(" + "\(Double(currentWeather.uv))" + ")"
        }
        else{
            uv.text = "위험" + "(" + "\(Double(currentWeather.uv))" + ")"
        }
        
        if (currentWeather.humidity >= 70){
            humidity.text = "높음" + "(" + "\(Double(currentWeather.humidity))" + "%)"
        }
        else{
            humidity.text = "낮음" + "(" + "\(Double(currentWeather.humidity))" + "%)"
        }
    }
    
    // 시간별 날씨예보 받는 부분
    func downloadHourlyWeather(completed: @escaping DownloadComplete){
        callAPI(strURL: FORECAST_API_URL) { value in
            var loopCnt: Int = 0
            if let dictionary = value as? Dictionary<String, AnyObject> {
                if let list = dictionary["hourly"] as? [Dictionary<String, AnyObject>]{
                    for item in list{
                        if loopCnt > 13{
                            break
                        }
                        let hourly = HourlyWeather(weatherDict: item)
                        self.hourlyArray.append(hourly)
                        loopCnt += 1
                    }
                    self.hourlyArray.remove(at: 0)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func getTipByTemp() {
        let strURL = "\(AZWEBAPP_URL)/tip/\(Int(currentWeather.currentTemp))"
        
        callAPI(strURL: strURL, method: .get) { value in
            let json = JSON(value)
            let tip = json["data"]["ootd_tip"].stringValue
            
            self.tipLbl.text = tip
        }
    }
    
}

extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyArray.count
        // .count로 하지 않으면, index out of range 오류가 뜨니 조심하자
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCollectionViewCell.identifier, for: indexPath) as? WeatherCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.configureCell(HourlyData: hourlyArray[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width:50, height:50)
    }
    
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // manager.startUpdatingLocation() // 계속 이동하면 계속적으로 정보 불러옴
        // 정확도에 따라 배열로 다양한 값이 들어올 수 있지만 제일 마지막으로 들어온 값이 필요
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            print("locationManager - didUpdateLocations")
            print(lat, lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // magneticHeading: 자성
        // trueHeading: (북: 0 / 서:90 / 남: 180 / 동: 270)
        // 비콘: 블루투스 / 특정 region 인식
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
