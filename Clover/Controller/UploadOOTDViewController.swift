//
//  UploadOOTDViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/30.
//

import UIKit
import Alamofire
import SwiftyJSON
import RxSwift
import RxCocoa

class UploadOOTDViewController: UIViewController {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var clothesCollectionView: UICollectionView!
    @IBOutlet weak var ootdView: UIView!
    
    var userInfo = UserDefaults.standard
    var clothesImages:[String]?
    var calendarVC:CalendarViewController?
    var date:String?
    var selectedCategory = "가방"
    var selectedCategoryIdx = 0
    let bag = DisposeBag()
    let azBlobStorage = AZBlobStorage(container: "clothes")
    
    override func viewWillAppear(_ animated: Bool) {
        getClothesByCategory(category: selectedCategory)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userInfo.stringArray(forKey: "categories") == nil {
            getCategories()
        }
        
        if let date = date {
            dateLbl.text = date
        }
    }
    
    @IBAction func actBack(_ sender: Any) {
        self.calendarVC?.viewWillAppear(true)
        self.calendarVC?.getDates()
        self.dismiss(animated: true)
    }
    
    @IBAction func uploadOOTDDetail(_ sender: Any) {
        if let uploadOOTDDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "upload_ootd_detail_vc") as? UploadOOTDDetailViewController {
            
            // 코디 이미지 전달
            let viewCnt = self.ootdView.subviews.count
            
            if viewCnt == 0 {
                self.showResult(title: "코디 등록", message: "코디를 완성해주세요.")
            } else {
                guard let image = self.ootdView.transfromToImage() else { return }
                
                uploadOOTDDetailVC.ootdImage = image
                uploadOOTDDetailVC.date = date
            }
            
            uploadOOTDDetailVC.modalPresentationStyle = .fullScreen
            present(uploadOOTDDetailVC, animated: true)
        }
    }
    
    @IBAction func cleanOOTD(_ sender: Any) {
        for view in self.ootdView.subviews { view.removeFromSuperview() }
    }
    
    func getCategories() {
        let strURL = "\(AZWEBAPP_URL)/category/"
        
        callAPI(strURL: strURL, method: .get) { value in
            let json = JSON(value)
            
            var categories:[String] = []
            
            guard let data = json["data"].arrayObject as? [[String:Any]] else { return}
            
            for item in data {
                guard let category = item["category_name"] as? String else { return }
                categories.append(category)
            }
            
            self.userInfo.setValue(categories, forKey: "categories")
            
            DispatchQueue.main.async {
                self.categoryCollectionView.reloadData()
            }
        }
    }
    
    func getClothesByCategory(category: String) {
        // 옷 정보 불러오기
        guard let accountId = userInfo.string(forKey: "accountId") else { return }
        guard let category = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return }
        
        let strURL = "\(AZWEBAPP_URL)/clothes/\(accountId)/\(category)"
        
        callAPI(strURL: strURL, method: .get) { value in
            let json = JSON(value)
            let success = json["success"].boolValue
            
            var filenames:[String] = []
            
            if success {
                guard let data = json["data"].arrayObject as? [[String:Any]] else { return}
                
                for item in data {
                    guard let filename = item["image_filename"] as? String else { return }
                    filenames.append(filename)
                }
            }
            
            self.clothesImages = filenames
            
            DispatchQueue.main.async {
                self.clothesCollectionView.reloadData()
            }
        }
    }
    
}

extension UploadOOTDViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            guard let categories = userInfo.array(forKey: "categories") else { return 0 }
            
            return categories.count
        } else {
            guard let clothesImages = clothesImages else { return 0 }
            
            return clothesImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category_cell", for: indexPath) as? CategoryCell else {
                return UICollectionViewCell()
            }
            
            cell.setupLayout()
            if selectedCategoryIdx == indexPath.row {
                cell.selectCell()
            }
            
            if let categories = userInfo.array(forKey: "categories") as? [String] {
                cell.categoryLbl.text = categories[indexPath.row]
            }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ootd_clothes_cell", for: indexPath) as? ClothesCell else {
                return UICollectionViewCell()
            }
            
            cell.setupLayout(backView: cell.clothesView)
            
            if let clothesImages = clothesImages {
                let image_filename = clothesImages[indexPath.row]
                
                azBlobStorage.downloadImage(filename: image_filename) { data in
                    if let data = data {
                        cell.clothesImageView.image = UIImage(data: data)
                    }
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            if let categories = userInfo.array(forKey: "categories") as? [String] {
                selectedCategory = categories[indexPath.row]
                getClothesByCategory(category: selectedCategory)
            }
            
            selectedCategoryIdx = indexPath.row
            
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
        } else {
            guard let clothesImages = clothesImages else { return }
            
            let image_filename = clothesImages[indexPath.row]
            var imageView:UIImageView!
            imageView = UIImageView(frame: CGRect(x:0, y:0, width:150, height:150))
            
            imageView.contentMode = .scaleAspectFit
            imageView.layer.position = CGPoint(x:ootdView.bounds.width/2, y:ootdView.bounds.height/2)
            
            azBlobStorage.downloadImage(filename: image_filename) { data in
                if let data = data {
                    imageView.image = UIImage(data: data)
                }
            }
            
            ootdView.addSubview(imageView)
            
            imageView.isUserInteractionEnabled = true
            setupInputBinding(myView:imageView)
        }
    }
    
    private func setupInputBinding(myView:UIImageView) {
        let panGesture = UIPanGestureRecognizer()
        myView.addGestureRecognizer(panGesture)
        panGesture.rx.event.asDriver { _ in .never() }
        .drive(onNext: { [weak self] sender in
            guard let view = self?.view,
                  let senderView = sender.view else {
                      return
                  }
            
            // view에서 움직인 정보
            let transition = sender.translation(in: view)
            senderView.center = CGPoint(x: senderView.center.x + transition.x, y: senderView.center.y + transition.y)
            
            sender.setTranslation(.zero, in: view) // 움직인 값을 0으로 초기화
        }).disposed(by: bag)
    }
    
}

extension UIView {
    func transfromToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
}
