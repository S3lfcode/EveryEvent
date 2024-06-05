//
//  StorageService.swift
//  EveryEvent
//
//  Created by S3lfcode on 03.05.2024.
//

import Foundation
import FirebaseStorage

final class StorageService {
    static let shared = StorageService()
    
    private let storage = Storage.storage().reference()
    
    typealias UploadPictureCompletion = (Result<String, Error>) -> Void

    ///Загрузка фото профиля на сервер
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { meta, error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url else {
                    print("Не получили адрес для загрузки")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    ///Загрузка фото в диалоге
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil) { meta, error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("message_images/\(fileName)").downloadURL { url, error in
                guard let url else {
                    print("Не получили адрес для загрузки")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    ///Загрузка фото мероприятия
    public func uploadEventPhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("event_images/\(fileName)").putData(data, metadata: nil) { meta, error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("event_images/\(fileName)").downloadURL { url, error in
                guard let url else {
                    print("Не получили адрес для загрузки")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
    }

    ///Загрузка ссылки для скачивания фото
    public func downloadURL(for path: String, completion: @escaping ((Result<URL, StorageErrors>) -> Void)) {
        let reference = storage.child(path)
        
        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
}
