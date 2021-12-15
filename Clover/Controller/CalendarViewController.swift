//
//  MainViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/25.
//

import UIKit
import FSCalendar
import Alamofire
import SwiftyJSON

class CalendarViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var ootdCollectionView: UICollectionView!
    @IBOutlet weak var removeBtn: UIBarButtonItem!
    
    let azBlobStorage = AZBlobStorage(container: "ootd")
    var selectedDate:Date?
    var date:String?
    var dateFormatter = DateFormatter()
    var userInfo = UserDefaults.standard
    var ootds:[OOTDModel.Data]?
    var dates:[Date] = []
    var flag = false
    
    override func viewWillAppear(_ animated: Bool) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // 선택된 날짜
        if let selectedDate = selectedDate {
            date = dateFormatter.string(from: selectedDate)
        } else {
            guard let today = calendar.today else { return }
            date = dateFormatter.string(from: today)
        }
        
        getOOTDByDate(date: date!)
        if !flag {
            getDates()
            flag = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDates()
        
        calendar.dataSource = self
        calendar.delegate = self
        calendar.appearance.eventOffset = CGPoint(x: 0, y: 0)
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0 // 헤더 전후 글씨 없애기
        calendar.appearance.headerTitleFont = UIFont(name: "Pretendard-Bold", size: 15)
        calendar.appearance.weekdayFont = UIFont(name: "Pretendard-Bold", size: 13)
        calendar.appearance.titleFont = UIFont(name: "Pretendard-Medium", size: 13)
        // calendar.locale = Locale(identifier: "ko_KR")
        
        calendar.calendarWeekdayView.weekdayLabels[0].text = "Su"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "Mo"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "Tu"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "We"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "Th"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "Fr"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "Sa"
        
        // calendar.scope = .week
        calendar.placeholderType = .none
        
        ootdCollectionView.allowsMultipleSelection = true
    }
    
    @IBAction func removeClothes(_ sender: Any) {
        if let selectedCells = ootdCollectionView.indexPathsForSelectedItems {
            // 1
            let items = selectedCells.map { $0.item }.sorted().reversed()
            // 2
            for item in items {
                guard let ootds = self.ootds else { return }
                let selected = ootds[item]
                let ootdId = selected.ootdId
                let strURL = "\(AZWEBAPP_URL)/ootd/\(ootdId)"
                
                callAPI(strURL:strURL, method:.delete) { value in
                    self.getDates()
                    self.azBlobStorage.deleteImage(filename: selected.imageFilename)
                }
                
                ootdCollectionView.deleteItems(at: selectedCells)
            }
            // 3
            removeBtn.isEnabled = false
            self.viewWillAppear(true)
        }
    }
    
    @IBAction func uploadOOTD(_ sender: Any) {
        if let uploadOOTDVC = self.storyboard?.instantiateViewController(withIdentifier: "upload_ootd_vc") as? UploadOOTDViewController {
            
            uploadOOTDVC.calendarVC = self
            
            if let date = date {
                uploadOOTDVC.date = date
            }
            
            uploadOOTDVC.modalPresentationStyle = .fullScreen
            present(uploadOOTDVC, animated: true)
        }
    }
    
    func getOOTDByDate(date: String) {
        guard let date = self.date,
              let date = date.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let accountId = UserDefaults.standard.string(forKey: "accountId")
        else { return }
        
        let strURL = "\(AZWEBAPP_URL)/ootd/\(accountId)/\(date)"
        
        callAPI(strURL: strURL, method: .get) { value in
            let json = JSON(value).description
            let decoder = JSONDecoder()
            
            guard let data = json.data(using: .utf8),
                  let ootdInfo = try? decoder.decode(OOTDModel.OOTD.self, from: data)
            else { return }
            
            self.ootds = ootdInfo.data
            
            DispatchQueue.main.async {
                self.ootdCollectionView.reloadData()
            }
        }
    }
    
    func getDates() {
        guard let accountId = UserDefaults.standard.string(forKey: "accountId") else { return }
        let strURL = "\(AZWEBAPP_URL)/ootd/dates/\(accountId)"
        
        callAPI(strURL: strURL, method: .get) { value in
            let json = JSON(value)
            let dates = json["dates"].arrayObject as! [String]
            
            let formatter = DateFormatter()
            // formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy-MM-dd"
            
            var temp:[Date] = []
            
            for date in dates {
                if let date = formatter.date(from: date) {
                    temp.append(date)
                }
            }
            
            self.dates = temp
            
            DispatchQueue.main.async {
                self.calendar.reloadData()
            }
        }
        
    }
    
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        self.viewWillAppear(true)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if self.dates.contains(date){
            return 1
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        if date == calendar.today {
            return "오늘"
        } else {
            return nil
        }
    }
    
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let ootds = ootds {
            return ootds.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ootd_cell", for: indexPath) as? OOTDCell else {
            return UICollectionViewCell()
        }
        
        cell.setupLayout(backView: cell.ootdView)
        
        if let ootds = ootds {
            let image_filename = ootds[indexPath.row].imageFilename
            
            azBlobStorage.downloadImage(filename: image_filename) { data in
                if let data = data {
                    cell.ootdImageView.image = UIImage(data: data)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? OOTDCell else { return }
        cell.selectCell(backView: cell.ootdView)
        
        if !isEditing {
            removeBtn.isEnabled = true
        } else {
            removeBtn.isEnabled = false
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? OOTDCell else { return }
        cell.setupLayout(backView: cell.ootdView)
        
        if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.count == 0 {
            removeBtn.isEnabled = false
        }
    }
    
}
