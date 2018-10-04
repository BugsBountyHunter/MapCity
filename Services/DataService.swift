//
//  DataService.swift
//  MapCity
//
//  Created by AHMED SR on 10/3/18.
//  Copyright © 2018 AHMED SR. All rights reserved.
//

import Foundation
import AlamofireImage
import Alamofire

class DataService{
    
    static let instanc = DataService()
    //Variabel
    var imageURLArray = [String]()
    var imageArray = [UIImage]()
    
    //FUNCTION:
    func flickrURL(forApiKey apiKey:String ,withAnnotation annotation:DroppablePoint ,andNumberOfPhoto number:Int)->String{
        let URL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
        return URL
    }
    //Retrive Data from Flickr URL
    func retriveURLS(forAnnotation annotation:DroppablePoint ,handler:@escaping(_ status:Bool)->()){
        Alamofire.request(flickrURL(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhoto: 40)).responseJSON { (respons) in
            guard let json = respons.result.value as? Dictionary<String,AnyObject> else{return}
            print(json)
            let photosDict = json["photos"] as! Dictionary<String,AnyObject>
            let photoDictArray = photosDict["photo"] as! [Dictionary<String,AnyObject>]
            for photo in photoDictArray {
            //https://farm2.staticflickr.com/1916/30109181187_c63839e541_o_d.jpg
            //https://farm2.staticflickr.com/1923/30140214097_b241cdf0a3_h_d.jpg
            // number of farm  ++ server ++ id ++ secret
//            let farm = photo["farm"]?.stringValue
//            let server = photo["server"]?.stringValue
//            let id = photo["id"]?.stringValue
//            let secret = photo["secret"]?.stringValue
//            let postURL = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_h_d.jpg"
            let postURL = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageURLArray.append(postURL)
            }
            handler(true)
        }
    }
    //Retrive image from imageUrlsArray
    func retriveImage(handler:@escaping(_ status:Bool)->()){
        
        for url in imageURLArray {
            Alamofire.request(url).responseImage { (respons) in
                guard let image = respons.result.value else{return}
                self.imageArray.append(image)
                MapVC.progressLbl?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED..."
                print(self.imageArray.count)
                
                if self.imageArray.count == self.imageURLArray.count {
                    handler(true)
                }
            }
        }
       
    }
    func cancelAllSession(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
//            //for item in sessionDataTask {
//            item.camcel()
//
//        }
        }
    }
}
