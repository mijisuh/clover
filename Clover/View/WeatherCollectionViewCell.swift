//
//  WeatherCollectionViewCell.swift
//  Clover
//
//  Created by MIJI SUH on 2021/12/03.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "weather_cell"
    
    @IBOutlet weak var hourlyDateLbl: UILabel!
    @IBOutlet weak var hourlyIconImageView: UIImageView!
    @IBOutlet weak var hourlyTempLbl: UILabel!
    
    func configureCell(HourlyData: HourlyWeather){
        self.hourlyDateLbl.text = "\(HourlyData.date)"+"시"
        self.hourlyTempLbl.text = "\(Int(HourlyData.temp))"+"°"
        
        let TypeForHour = (Int)(HourlyData.date)
        
        if (TypeForHour! >= 19 && TypeForHour! <= 23 && HourlyData.weather=="Clear") {
            self.hourlyIconImageView.image = UIImage(named: "ClearMoon")
        }
        else if (TypeForHour! >= 0 && TypeForHour! <= 5 && HourlyData.weather=="Clear") {
            self.hourlyIconImageView.image = UIImage(named: "ClearMoon")
        }
        else if (TypeForHour! >= 19 && TypeForHour! <= 23 && HourlyData.weather=="overcast") {
            self.hourlyIconImageView.image = UIImage(named: "overcastMoon")
        }
        else if (TypeForHour! >= 0 && TypeForHour! <= 5 && HourlyData.weather=="overcast") {
            self.hourlyIconImageView.image = UIImage(named: "overcastMoon")
        }
        else{
            self.hourlyIconImageView.image = UIImage(named: HourlyData.weather)
        }
    }
    
}

