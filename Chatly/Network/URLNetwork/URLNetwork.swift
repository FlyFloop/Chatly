//
//  URLNetwork.swift
//  Chatly
//
//  Created by Alper Yorgun on 1.02.2023.
//

import Foundation
import UIKit
import FirebaseStorage


struct URLNetworkModel {
    
    func fetchImageWithUrl(handler:@escaping(UIImage?) ->(), url: URL?){
        guard let safeUrl = url else {return}
        let task = URLSession.shared.dataTask(with: safeUrl) {
            data, urlResponse, error in
            if error != nil {
                print(ErrorStrings.fetchImageWithUrlError)
                return
            }
            guard let imageData = data else {return}
            DispatchQueue.main.async {
            //    self.profilePhotoImageView.image = UIImage(data: imageData)
                let fetchedImage = UIImage(data: imageData)
                guard let safeImage = fetchedImage else {return}
                handler(safeImage)
            }
        }
        task.resume()
    }
    func fetchAndUploadGoogleImage(handler : @escaping(String?) -> (), url : URL?, ref : StorageReference) {
        guard let safeUrl = url else {return}
        let urlRequest = URLRequest(url: safeUrl)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if error != nil {
                print(ErrorStrings.fetchAndUploadGoogleImageError)
                handler(nil)
                return
            }
            guard let safeData = data else {return}
            ref.putData(safeData) { metaData, error in
                if error != nil {
                    print(ErrorStrings.fetchAndUploadImagePutDataError)
                    handler(nil)
                    return
                }
                ref.downloadURL { url, error in
                    if error != nil {
                        print(ErrorStrings.fetchAndUploadImageDownloadUrlError)
                        handler(nil)
                        return
                    }
                    handler(url?.absoluteString)
                }
            }
            
            
        }
        task.resume()
    }
    
}
