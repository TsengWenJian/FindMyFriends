//
//  NickMKAnnotationView.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/8/29.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import MapKit

class NickMKPointAnnotation:MKPointAnnotation {
    var imageURLStr:String?
    
    override init() {
        super.init()
    }
}


class NickMKAnnotationView: MKAnnotationView {
    
    var imageView = UIImageView()
    
    var caOvalLayer:CAShapeLayer?
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        self.frame = CGRect(x: 0, y: 0, width: 45, height: 100)
        
        imageView = UIImageView(frame:CGRect(x:2.5,y:2.5,width:40,height:40))
        self.addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        
      
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder);
        
        
    }
    
    override func draw(_ rect: CGRect) {
        
        
        if let _ = caOvalLayer{
             
            return
            
        }else{
            
            let ovalPath = UIBezierPath(ovalIn:CGRect(x:0,
                                                      y:0,
                                                      width:self.bounds.width,
                                                      height:self.bounds.width))
            
            let color = UIColor(red:50/255, green:180/255, blue: 255/255, alpha: 1)
            
            
            caOvalLayer = CAShapeLayer()
            caOvalLayer?.path = ovalPath.cgPath
            caOvalLayer?.fillColor = color.cgColor
            
            
            self.layer.addSublayer(caOvalLayer!)
            
            
            
            
            
            let trianglePath = UIBezierPath()
            trianglePath.move(to: CGPoint(x:1, y: self.bounds.width-15))
            trianglePath.addLine(to: CGPoint(x: self.bounds.width/2, y:self.bounds.maxY/2))
            trianglePath.addLine(to: CGPoint(x: self.bounds.width-1, y: self.bounds.width-15))
            trianglePath.close()
            
            
            let caTriangle = CAShapeLayer()
            caTriangle.path = trianglePath.cgPath
            caTriangle.fillColor = color.cgColor
            self.layer.addSublayer(caTriangle)
            
            self.bringSubview(toFront: imageView)
            
    
            
        }
        

        
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
