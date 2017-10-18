//
//  ViewController.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/20.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController{
    
    
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var tralling: NSLayoutConstraint!
    
    @IBOutlet weak var showName: UIButton!
    @IBOutlet weak var mapViewType: UISegmentedControl!
    @IBOutlet weak var detailButtonView: UIView!
    @IBOutlet weak var timerViewContainer: UIView!
    
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var friendsTableViewContainer: UIView!
    @IBOutlet weak var myLocationView: UIView!
    @IBOutlet weak var myLocationAddress: UITextView!
    
    
    let timerManager = MyTimerManager.standard
    let serviceManager = ServiceManager.standard
    let profileManager = ProfileManager.standard
    var friendVC:FriendsViewController?
    var timerVC:TimerViewController?
    
    
    
    
    var labelArray = [UILabel]()
    var locationArray = [CLLocationCoordinate2D]()
    var locationManager = CLLocationManager()
    
    
    var recordIsBegin = false
    var TimerViewIsDisplayed = false
    var friendViewIsDisplayed = false
    
    @IBOutlet weak var timerContainerViewTop: NSLayoutConstraint!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if profileManager.userID == nil{
            
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                self.dismiss(animated: false, completion: nil)
                UIApplication.shared.keyWindow?.rootViewController = viewController
                
            }
            
            return
        }
        
        
        switch CLLocationManager.authorizationStatus(){
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        //Refuse
        case .denied:
            
            myLocationAddress.text = "請至 設定 > 隱私權 > 定位服務 > 開啟"
            
        //First time
        case .notDetermined:
            
            locationManager.requestAlwaysAuthorization()
            
        default:
            break
        }
        
        uploadDiveToken()
        setViewFrameAndLayer()
        serviceManager.refreshFirendLocation()
        setRefreshDataInterval()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showFriendsOnMap),
                                               name: NSNotification.Name(rawValue: notification_downloadDone),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logOut),
                                               name: NSNotification.Name(rawValue: "logOut"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(setRefreshDataInterval),
                                               name: NSNotification.Name(rawValue:notifyName_updateFrequency),
                                               object: nil)
        
        
        myMapView.userTrackingMode = .follow
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false;
        locationManager.distanceFilter = 10
        locationManager.activityType = .automotiveNavigation
        locationManager.delegate = self
        
        
        DispatchQueue.main.async {
            self.checkLastRecord()
        }
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        locationManager.desiredAccuracy = profileManager.desiredAccuracy
        
        if profileManager.gotoBeginRecord{
            timerDisplayAction(self)
            profileManager.gotoBeginRecord = false
            timerVC?.startButtonAction(self)
        }
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:notification_downloadDone), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:notifyName_updateFrequency), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:notifyName_logOut), object: nil)
        
        SHLog(message:"---ViewController---deinit")
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: - IBAction
    
    @IBAction func displayFriendsVCBtn(_ sender: Any) {
        
        
        UIView.animate(withDuration:0.2) {
            
            if self.friendViewIsDisplayed{
                
                self.tralling.constant = -self.view.frame.width
                self.leading.constant = self.view.frame.width
                
                
                self.friendViewIsDisplayed = false
                
            }else{
                self.friendViewIsDisplayed = true
                self.leading.constant = 0
                self.tralling.constant = 0
                
                
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    @objc func logOut(){
        
        
        for child in self.childViewControllers{
            
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
            
        }
        
        navigationController?.popToViewController(self, animated: false)
        
        
    }
    
    @IBAction func showNameBtn(_ sender: UIButton) {
        
        
        if showName.isSelected{
            showName.isSelected = false
            showName.backgroundColor = UIColor(white:1, alpha: showName.alpha)
            
            
        }else{
            showName.isSelected = true
            showName.backgroundColor = UIColor(red:0,green:64/255, blue: 128/255,alpha: showName.alpha)
            
        }
        
        changeMapViewType(selectorIndex: nil)
        
        for label in labelArray{
            label.isHidden = !showName.isSelected
        }
        
        
    }
    
    
    
    @IBAction func displayMapViewTypeBtn(_ sender: UIButton) {
        
        
        
        mapViewType.isHidden = false
        detailButtonView.isHidden = true
        showName.isHidden = false
        UIView.animate(withDuration: 0.1) {
            let frame = self.detailButtonView.frame
            
            self.mapViewType.frame = CGRect(x:frame.minX-(frame.width*6),
                                            y:frame.minY,
                                            width:frame.width*7,
                                            height:frame.height-10)
            
            self.mapViewType.layer.cornerRadius = 5
            
            
            let mapTypeFrame = self.mapViewType.frame
            
            self.showName.frame = CGRect(x:mapTypeFrame.maxX-mapTypeFrame.width/3,
                                         y:mapTypeFrame.maxY+5,
                                         width:mapTypeFrame.width/3,
                                         height:mapTypeFrame.height)
            
            
        }
        
        
    }
    
    @IBAction func timerDisplayAction(_ sender: Any) {
        let pointY:CGFloat
        
        if TimerViewIsDisplayed{
            
            pointY = -timerViewContainer.frame.height
            TimerViewIsDisplayed = false
            
        }else{
            pointY = myMapView.frame.minY
            TimerViewIsDisplayed = true
            
        }
        
        UIView.animate(withDuration:0.3) {
            self.timerContainerViewTop.constant = pointY
            self.view.layoutIfNeeded()
        }
        
    }
    
    //MARK:- Fuction
    
    func uploadDiveToken() {
        if serviceManager.isConnectService{
            
            if let userId = profileManager.userID,
                let deviceToken = profileManager.deviceToken{
                
                serviceManager.updateDeviceToken(userID:userId,deviceToken: deviceToken)
                
            }
            
        }
    }
    
    func setViewFrameAndLayer(){
        
        tralling.constant = -view.frame.width
        leading.constant = view.frame.width
        timerContainerViewTop.constant = -timerViewContainer.frame.height
        
        detailButtonView.setShadowView(5, CGSize.zero,0.3)
        
        showName.layer.cornerRadius = 5
        showName.layer.borderColor = UIColor(red:0, green:64/255, blue:128/255, alpha: showName.alpha).cgColor
        showName.layer.borderWidth = 1
        
        
        
        let userTrackingItem = MKUserTrackingBarButtonItem(mapView: myMapView)
        
        let refreshBtn = UIBarButtonItem(barButtonSystemItem: .refresh,
                                         target:self,
                                         action:#selector(navBarRefreshBtn))
        
        navigationItem.rightBarButtonItems = [userTrackingItem,refreshBtn]
        
        
        
        
        for VC in self.childViewControllers{
            
            if VC.isKind(of:FriendsViewController.self){
                friendVC = VC as? FriendsViewController
                friendVC?.delegate = self
            }else{
                timerVC = VC as? TimerViewController
                timerVC?.delegate = self
            }
            
        }
        
    }
    
    @objc func showFriendsOnMap(){
        
        
        myMapView.removeAnnotations(myMapView.annotations)
        
        for friend in serviceManager.friends {
            addAnnotationOnMap(data:friend)
        }
        
    }
    
    
    @objc func setRefreshDataInterval(){
        let interval:TimeInterval = TimeInterval(profileManager.updateFrequency)
        serviceManager.resetRefreshFrequency(interval: interval)
    }
    
    @objc func navBarRefreshBtn(){
        
        serviceManager.refreshFirendLocation()
        
    }
    
    
    // if nil = user is touch showName butoon
    func changeMapViewType(selectorIndex:Int?) {
        
        UIView.animate(withDuration: 0.1, animations: {
            let frame = self.detailButtonView.frame
            
            self.mapViewType.frame = frame
            
            self.showName.frame = frame
            
        }) { (bool) in
            
            
            self.mapViewType.isHidden = true
            self.showName.isHidden = true
            self.detailButtonView.isHidden = false
            
            guard let index = selectorIndex else{
                return
            }
            
            switch index {
            case 0:
                self.myMapView.mapType = .standard
            case 1:
                self.myMapView.mapType = .hybrid
            case 2:
                self.myMapView.mapType = .satellite
            default:
                break
            }
        }
    }
    
    //Check that the last record has not been recorded
    func checkLastRecord(){
        
        
        let detailManager = MyLocationRecordsManager(.DetailRecord)
        let condition = "1=1 group by start_time"
        
        let detailRecords = detailManager.getDetailRecords(cond:condition,order: nil)
        
        guard let LaststartTime = detailRecords.last?.startTime,
            let totalTime =  detailRecords.last?.totalTime ,
            let distance = detailRecords.last?.distance else{
                return
        }
        
        
        let locationManager = MyLocationRecordsManager(.LocationRecord)
        let locationRecord = locationManager.getLocatoinRecord(cond: nil, order: nil)
        
        let startTime = locationRecord.last?.startTime
        
        
        let detailManager2 = MyLocationRecordsManager(.DetailRecord)
        let cond = "start_time = '\(LaststartTime)'"
        
        
        
        // locationRecord and detailRecord data is not same
        if LaststartTime != startTime {
            
            
            let alertVC =  UIAlertController(title:"找到過去的活動",message:"開始時間:\(LaststartTime)\n總時間:\(totalTime) 距離:\(distance)公尺",preferredStyle: .alert)
            let action = UIAlertAction(title: "繼續", style: .default, handler: { (UIAlertAction) in
                
                self.timerDisplayAction(self)
                self.timerVC?.startButtonAction(self)
                self.timerManager.setStartTime(time:LaststartTime)
                self.timerManager.setTimeInitial(totalTime)
                self.timerManager.setDistanceInitial(distance)
                
                let detail = detailManager2.getDetailRecords(cond:cond, order: nil)
                
                var coordArray = [CLLocationCoordinate2D]()
                for record in detail{
                    let coordinate = CLLocationCoordinate2D(latitude: record.lat, longitude: record.lon)
                    coordArray.append(coordinate)
                }
                
                let polyLine = MKPolyline(coordinates:coordArray, count:coordArray.count)
                self.myMapView.add(polyLine)
                
                
                
            })
            
            
            let cancel = UIAlertAction(title: "刪除", style: .cancel, handler: { (UIAlertAction) in
                
                detailManager2.deleteRecord(cond:cond)
            })
            
            alertVC.addAction(action)
            alertVC.addAction(cancel)
            present(alertVC, animated: true, completion: nil)
            
        }
        
    }
    
    
    func coordinateToAddress(coordinate:CLLocationCoordinate2D){
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude:coordinate.latitude, longitude:coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            
            if error != nil{
                //print(error.debugDescription)
                
                return
            }
            guard let placemark = placemarks?.first else{
                return
            }
            
            
            let addressDict = placemark.addressDictionary
            
            guard let addressNSArray = addressDict?["FormattedAddressLines"] as? NSArray else{
                return
            }
            
            for NSString in addressNSArray{
                
                
                guard let address = NSString as? NSString else{
                    return
                }
                
                DispatchQueue.main.async {
                    self.myLocationAddress.text = address as String
                }
            }
        }
    }
    
    func showAlertNotRecord(){
        let alertVC = UIAlertController(title: "紀錄", message: "移動距離過少或未取得位置，無法紀錄", preferredStyle:.alert)
        let action = UIAlertAction(title: "確認", style: .cancel, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    
    
    func addAnnotationOnMap(data:Friend){
        
        let pointAnnotation = NickMKPointAnnotation()
        pointAnnotation.coordinate  = CLLocationCoordinate2D(latitude:data.lat, longitude:data.lon)
        pointAnnotation.title = data.friendName
        pointAnnotation.subtitle = data.lastUpdateDateTime
        pointAnnotation.imageURLStr = data.photoURL
        
        
        myMapView.addAnnotation(pointAnnotation)
        
    }
    
}
// MARK: - MKMapViewDelegate
extension ViewController:MKMapViewDelegate{
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if annotation is MKUserLocation {
            
            return nil
        }
        
        
        if !annotation.isKind(of:NickMKPointAnnotation.self) {
            
            return nil
        }
        
        guard let nickAnnotation = annotation as? NickMKPointAnnotation else{
            
            return nil
        }
        
        
        let identifier = "MyPin"
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? NickMKAnnotationView
        
        
        if result == nil{
            
            
            result = NickMKAnnotationView(annotation:nickAnnotation,reuseIdentifier: identifier)
            
            
            let namelabel = UILabel()
            
            if let myTitle = nickAnnotation.title{
                
                namelabel.text = " \(myTitle) "
                namelabel.sizeToFit()
                namelabel.frame.origin = CGPoint(x:-namelabel.frame.width-5, y: 0)
                namelabel.backgroundColor = UIColor.white
                namelabel.alpha = 0.9
                namelabel.setShadowView(0,CGSize.zero, 0.3)
                
                result?.addSubview(namelabel)
                namelabel.isHidden = !showName.isSelected
                labelArray.append(namelabel)
                
            }
            
            
        }else{
            
            result?.annotation = nickAnnotation
            
            if  let label = result?.subviews.first as? UILabel{
                label.text =  nickAnnotation.title!
                label.sizeToFit()
                label.frame.origin = CGPoint(x:-label.frame.width, y: 0)
                
            }
            
        }
        
        
        if let urlStr = nickAnnotation.imageURLStr{
            result?.imageView.loadImageWithNSCach(url:urlStr)
            
            
        }else{
            result?.imageView.image = UIImage(named: "user")
        }
        
        
        result?.canShowCallout = true
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width:50, height:50)
        button.setTitle("導航", for: .normal)
        button.titleLabel?.textColor = UIColor.white
        button.backgroundColor = UIColor.red
        result?.rightCalloutAccessoryView = button
        
        return result
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
     
        if let annotation = view.annotation,
            let name = annotation.title{
            let targetCoordinate = annotation.coordinate
            let targetMark = MKPlacemark(coordinate: targetCoordinate)
            let target = MKMapItem(placemark: targetMark)
            target.name = name
            let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking]
            target.openInMaps(launchOptions: options)
        }
       
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red:0,green:0.6, blue:1, alpha:1)
        renderer.lineWidth = 4.0
        
        
        return renderer
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let coordinate = view.annotation?.coordinate{
            
            let region = MKCoordinateRegionMakeWithDistance(coordinate,1000, 1000)
            myMapView.setRegion(region, animated: true)
        }
        
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension ViewController:UIGestureRecognizerDelegate{
    
    // Use the Point x to determine which mapviewType(Segmented) was tap
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        let pointX = touch.location(in:touch.view).x
        let width = mapViewType.frame.width/3
        
        if pointX < width{
            mapViewType.selectedSegmentIndex = 0
            
        }else if pointX > width && pointX < width*2{
            
            mapViewType.selectedSegmentIndex = 1
            
        }else{
            
            mapViewType.selectedSegmentIndex = 2
            
            
        }
        changeMapViewType(selectorIndex: mapViewType.selectedSegmentIndex)
        
        
        return true
    }
    
    
}

// MARK: - CLLocationManagerDelegate
extension ViewController:CLLocationManagerDelegate{
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        guard let clLocation = locations.last else{
            return
        }
        
        let coordinate = clLocation.coordinate
        
        
        if recordIsBegin{
            
            
            
            if locationArray.count != 0{
                
                
                // Point one
                guard let firstPoint = locationArray.last else{
                    return
                }
                // Point two
                let lastPoint = coordinate
                
                
                
                
                let lastLocation = CLLocation(latitude:firstPoint.latitude,longitude: firstPoint.longitude)
                // Calculate the two distances and plus
                timerManager.distance += Int(round(clLocation.distance(from:lastLocation)))
                
                let polyLine = MKPolyline(coordinates:[firstPoint,lastPoint],count: 2)
                myMapView.add(polyLine)
                
                let manager = MyLocationRecordsManager(.DetailRecord)
                let record = DetailRecord(id:nil,
                                          startTime:timerManager.startTime,
                                          totalTime: timerManager.timeString,
                                          lat:coordinate.latitude,
                                          lon: coordinate.longitude,
                                          distance: timerManager.distance)
                // insert into sqlite
                manager.insertDetailRecord(record:record)
                
                
                
            }
            locationArray.append(coordinate)
            
            
            
            
        }
        
        
        if serviceManager.isConnectService{
            
            if profileManager.userisShareing{
                
                serviceManager.uploadUserLocation(lat:coordinate.latitude, lon:coordinate.longitude)
            }
            
            
            coordinateToAddress(coordinate:coordinate)
        }else{
            
            myLocationAddress.text = "無法連接至網路"
        }
    }
    
    
    
}

// MARK: - FriendsVCDelegate
extension ViewController:FriendsVCDelegate{
    
    func getDidSelectRowAt(row: Int) {
        
        let lat =  serviceManager.friends[row].lat
        let lon =  serviceManager.friends[row].lon
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude:lon)
        
        let regionDistance = MKCoordinateRegionMakeWithDistance(coordinate,50, 50)
        myMapView.setRegion(regionDistance, animated: true)
        
        friendViewIsDisplayed = true
        displayFriendsVCBtn(self)
    }
}
//MARK: -TimerVCDelegate
extension ViewController:TimerVCDelegate{
    
    func getTimerStatus(status:TimerStatus) {
        
        
        switch status {
            
        case .start:
            recordIsBegin = true
            
            
            break
        case .pause:
            recordIsBegin = false
            locationArray.removeAll()
            
            break
        case .none:
            recordIsBegin = false
            
            // if lat lon empty don't save
            if timerManager.distance < 10{
                showAlertNotRecord()
                break
            }
            
            
            let manager = MyLocationRecordsManager(.LocationRecord)
            let record = LocationRecord(id:nil,
                                        startTime:timerManager.startTime,
                                        totalTime:timerManager.timeString
            )
            manager.insertLocatoinRecord(record: record)
            
            locationArray.removeAll()
            myMapView.removeOverlays(myMapView.overlays)
            
            
            
        }
        
        
        
    }
}

