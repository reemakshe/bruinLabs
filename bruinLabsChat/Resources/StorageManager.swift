//
//  StorageManager.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 8/1/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, filename: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(filename)").putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                completion(.failure(StorageErrors.failedToUpload))
            }
            
            self.storage.child("images/\(filename)").downloadURL { (url, error) in
                guard let url = url else {
                    print("Failed to get download")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                completion(.success(urlString))
                print("download url: \(urlString)")
            }
        }
    }
    
    public enum StorageErrors: Error{
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path : String, completion : @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        reference.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        }
    }
}
