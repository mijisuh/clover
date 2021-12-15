//
//  AZBlobStorage.swift
//  Clover
//
//  Created by MIJI SUH on 2021/12/09.
//

import AZSClient
import UIKit

class AZBlobStorage {
    var blobContainer:AZSCloudBlobContainer?
    
    init(container: String) {
        guard let account = try? AZSCloudStorageAccount(fromConnectionString: AZSTORAGE_CONNECTION_STRING) else { return } // 스토리지 계정 연결
        
        let blobClient = account.getBlobClient() // 클라이언트 생성
        
        self.blobContainer = blobClient.containerReference(fromName: container)
    }
    
    func uploadImage(data: Data) -> String {
        guard let blobContainer = blobContainer else { return "" }
        let filename = self.getFileName()
        
        blobContainer.createContainerIfNotExists { error, exist in // 컨테이너 생성
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // 블랍 생성
            let blockBlob = blobContainer.blockBlobReference(fromName: filename) // 저장될 이름
            
            // 사진 데이터 가져와서 저장 (SNS 프로필/사진첩)
            if let data = UIImage(data: data)?.pngData() {
                blockBlob.upload(from: data) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        }
        
        return filename
    }
    
    func downloadImage(filename: String, completion: @escaping (Data?)-> ()) {
        guard let blobContainer = blobContainer else { return }
        
        let blockBlob = blobContainer.blockBlobReference(fromName: filename)
        
        blockBlob.downloadToData { error, data in
            if let error = error {
                print(error.localizedDescription.description)
                return
            }
            
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
    
    func deleteImage(filename: String) {
        guard let blobContainer = blobContainer else { return }
        
        let blockBlob = blobContainer.blockBlobReference(fromName: filename)
        blockBlob.delete { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func getFileName() -> String {
        // 파일 이름 중복 처리 -> 날짜로 하거나 processInfo
        let uniquename = ProcessInfo.processInfo.globallyUniqueString
        let filename = "\(uniquename).png"
        
        return filename
    }
    
}
