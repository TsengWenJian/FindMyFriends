//
//  Extensions.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/8/17.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

func SHLog<T>(message:T,
           fileName: NSString = #file,
           methodName: String = #function,
           lineNumber: Int = #line){
    
    #if DEBUG
        print("(\(fileName.lastPathComponent))\(methodName)[\(lineNumber)]:\(message)")
    #endif
}


let imageCach = NSCache<AnyObject, AnyObject>()


extension UIView{
    
    func setShadowView(_ cornerRadius:CGFloat,_ offSet:CGSize, _ Opacity:Float){
        
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = offSet
        layer.shadowOpacity = Opacity
        
    }
    
    
}
extension UIImage{
    
    
    func writeToFile(imageName:String,search:FileManager.SearchPathDirectory){
        
        let cachesURL = FileManager.default.urls(for:search,in:.userDomainMask).first
        
        
        guard let fullFileImageURL = cachesURL?.appendingPathComponent(imageName) else {
            
            return
        }
        
        let imageData = UIImageJPEGRepresentation(self,1)
        
        guard let _ = try? imageData?.write(to:fullFileImageURL,options: [.atomic]) else{
            
            SHLog(message:"write photo into file error")
            
            return
        }
        
    }
    
    
    convenience init?(imageName:String?,search:FileManager.SearchPathDirectory){
        
        
        guard let cachesURL = FileManager.default.urls(for:search,in:.userDomainMask).first,
              let name = imageName else{
                return nil
        }
    
        let fullFileImageName = cachesURL.appendingPathComponent(name)
        self.init(contentsOfFile:fullFileImageName.path)
        
    }
    
    func resizeImage(maxLength:CGFloat)->UIImage{
        
        var finalImage = UIImage()
        var targetSize = size;
        
        if size.width <= maxLength
            && size.height <= maxLength{
            finalImage = self;
            targetSize = size;
            
        } else {
            // Will do resize here,and decide final size first.
            if size.width >= size.height {
                // Width >= Height
                let ratio = size.width / maxLength;
                targetSize = CGSize(width:maxLength,height:size.height/ratio);
            } else {
                // Height > Width
                let ratio = size.height / maxLength;
                targetSize = CGSize(width:size.width/ratio,height:maxLength);
            }
            // Do resize job here.
            UIGraphicsBeginImageContext(targetSize);
            draw(in:CGRect(x: 0, y: 0,width:targetSize.width,height: targetSize.height))
            
            finalImage = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();    // Important!!!
        }
        
        
        return  finalImage
        
    }
}



extension UIImageView{
    
    func loadImageWithNSCach(url:String){
    
            image = nil
        
        if  let cachImage = imageCach.object(forKey: url as AnyObject),
            let cachData = cachImage as? Data{
            
            
            self.image = UIImage(data:cachData)
            
            return
        }
        
        
        guard let URL = URL(string:url) else{
            return
        }
        
        
        let config = URLSessionConfiguration.default
        let task = URLSession(configuration: config).dataTask(with: URL) { (data, respone, error) in
            
            
            if error != nil{
                
                SHLog(message:error.debugDescription)
                
                return
                
            }
            
            guard let imageData = data else{
                
                return
            }
            
            
            imageCach.setObject(imageData as AnyObject,forKey: url as AnyObject)
            
            DispatchQueue.main.async {
                self.image = UIImage(data:imageData)
            }
        }
        
        
        task.resume()
        
        
    }
    
    
    
}
