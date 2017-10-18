//
//  ShowLocationRecordViewController.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import MapKit

class ShowLocationRecordViewController: UIViewController {
    @IBOutlet weak var myMapView: MKMapView!
    var startTime:String = ""
    var recordArray = [DetailRecord]()
    var corrdinateArray = [CLLocationCoordinate2D]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let cond = "start_time ='\(startTime)'"
        
        
        let manager = MyLocationRecordsManager(.DetailRecord)
        
        recordArray =  manager.getDetailRecords(cond: cond, order:nil)
        navigationItem.title = recordArray.first?.startTime
        
        for record in recordArray{
            makeCorrdinate(lat:record.lat,lon:record.lon)
        }
        
        
        
        
        let mkPoly = MKPolyline(coordinates:corrdinateArray, count:corrdinateArray.count)
        
        
        myMapView.add(mkPoly, level: .aboveRoads)
        
        
        guard let sourceLocation = corrdinateArray.first,
            let targetLocation = corrdinateArray.last,
            let targerTotalTime = recordArray.last?.totalTime,
            let distance = recordArray.last?.distance else{
                
                return
        }
        
        
        let span = MKCoordinateSpan(latitudeDelta:0.01, longitudeDelta:0.01)
        let region = MKCoordinateRegion(center:sourceLocation, span:span )
        myMapView.setRegion(region, animated: true)
        
        
        let sourceCorrdinate = sourceLocation
        let targetCorrdinate = targetLocation
        
        let sourceAnnotation = MKPointAnnotation()
        let targetAnnotation = MKPointAnnotation()
        
        
        sourceAnnotation.coordinate = sourceCorrdinate
        targetAnnotation.coordinate = targetCorrdinate
        sourceAnnotation.title = "開始"
        targetAnnotation.title = "結束"
        targetAnnotation.subtitle = "花費:\(targerTotalTime)距離:\(distance)公尺"
        
        
        
        myMapView.addAnnotations([sourceAnnotation,targetAnnotation])
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Fuction
    func makeCorrdinate(lat:Double,lon:Double){
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        corrdinateArray.append(coordinate)
        
        
    }
    
    

}

//MARK: - MKMapViewDelegate
extension ShowLocationRecordViewController:MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 0, green: 0.6, blue: 0.9, alpha: 0.95)
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MyPin"
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if result == nil{
            result = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }else{
            result?.annotation = annotation
        }
        result?.canShowCallout = true
        
        let title = annotation.title!
        
        if title == "結束"{
            (result as! MKPinAnnotationView).pinTintColor = UIColor.brown
            
        }
        
        return result
    }
}

