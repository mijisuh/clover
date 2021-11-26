//
//  MainViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/25.
//

import UIKit
import FSCalendar

class MainViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.dataSource = self
        calendar.delegate = self
        calendar.appearance.eventOffset = CGPoint(x: 0, y: 0)
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0 // 헤더 전후 글씨 없애기
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
    }

}

extension MainViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
}
