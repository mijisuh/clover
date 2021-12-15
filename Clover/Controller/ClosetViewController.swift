//
//  ClosetViewController.swift
//  Clover
//
//  Created by MIJI SUH on 2021/11/29.
//

import UIKit
import Alamofire
import SwiftyJSON

class ClosetViewController: UIViewController {
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var clothesCollectionView: UICollectionView!
    @IBOutlet weak var removeBtn: UIBarButtonItem!
    
    let azBlobStorage = AZBlobStorage(container: "clothes")
    var userInfo = UserDefaults.standard
    var clothes:[ClothesModel.Data]?
    var selectedCategory = "가방"
    var selectedCategoryIdx = 0
    
    override func viewWillAppear(_ animated: Bool) {
        getClothesByCategory(category: selectedCategory)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userInfo.stringArray(forKey: "categories") == nil {
            getCategories()
        }
        
        clothesCollectionView.allowsMultipleSelection = true
    }
    
    @IBAction func removeClothes(_ sender: Any) {
        if let selectedCells = clothesCollectionView.indexPathsForSelectedItems {
            // 1
            let items = selectedCells.map { $0.item }.sorted().reversed()
            // 2
            for item in items {
                guard let clothes = self.clothes else { return }
                let selected = clothes[item]
                let clothesId = selected.clothesId
                let strURL = "\(AZWEBAPP_URL)/clothes/\(clothesId)"
                
                callAPI(strURL:strURL, method:.delete) { value in
                    self.azBlobStorage.deleteImage(filename: selected.imageFilename)
                }
                
                clothesCollectionView.deleteItems(at: selectedCells)
            }
            // 3
            
            removeBtn.isEnabled = false
            
            self.viewWillAppear(true)
        }
    }
    
    @IBAction func uploadClothes(_ sender: Any) {
        if let uploadClothesVC = self.storyboard?.instantiateViewController(withIdentifier: "upload_clothes_vc") as? UploadClothesViewController {
            
            uploadClothesVC.closetVC = self
            uploadClothesVC.modalPresentationStyle = .fullScreen
            self.present(uploadClothesVC, animated: true)
        }
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
        removeBtn.isEnabled = false
        
        // 옷 정보 불러오기
        guard let accountId = userInfo.string(forKey: "accountId"),
              let category = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return }
        
        let strURL = "\(AZWEBAPP_URL)/clothes/\(accountId)/\(category)"
        
        callAPI(strURL: strURL, method: .get) { value in
            let json = JSON(value).description
            
            let decoder = JSONDecoder()
            
            guard let data = json.data(using: .utf8),
                  let clothesInfo = try? decoder.decode(ClothesModel.Clothes.self, from: data)
            else { return }
            
            self.clothes = clothesInfo.data
            
            DispatchQueue.main.async {
                self.clothesCollectionView.reloadData()
            }
        }
    }
    
}

extension ClosetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            guard let categories = userInfo.array(forKey: "categories") else { return 0 }
            
            return categories.count
        } else {
            guard let clothes = clothes else { return 0 }
            
            return clothes.count
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clothes_cell", for: indexPath) as? ClothesCell else {
                return UICollectionViewCell()
            }
            
            if let clothes = clothes {
                let image_filename = clothes[indexPath.row].imageFilename
                
                azBlobStorage.downloadImage(filename: image_filename) { data in
                    if let data = data {
                        cell.clothesImageView.image = UIImage(data: data)
                    }
                }
            }
            
            cell.setupLayout(backView: cell.clothesView)
            
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
            guard let cell = clothesCollectionView.cellForItem(at: indexPath) as? ClothesCell else { return }
            cell.selectCell(backView: cell.clothesView)
            
            if !isEditing {
                removeBtn.isEnabled = true
            } else {
                removeBtn.isEnabled = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == clothesCollectionView {
            guard let cell = clothesCollectionView.cellForItem(at: indexPath) as? ClothesCell else { return }
            cell.setupLayout(backView: cell.clothesView)
            
            if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.count == 0 {
                removeBtn.isEnabled = false
            }
        }
    }
    
}
