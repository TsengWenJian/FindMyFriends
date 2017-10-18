//
//  FriendsViewController.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/25.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


protocol FriendsVCDelegate:class {
    
    func getDidSelectRowAt(row:Int)
    
}

class FriendsViewController: UIViewController{
    
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var friendsTableView: UITableView!
    let refreshControl = UIRefreshControl()
    weak var delegate:FriendsVCDelegate? = nil
    let serviceManager = ServiceManager.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        friendsTableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name:NSNotification.Name(rawValue: notification_downloadDone), object: nil)
        
        shadowView.setShadowView(10,CGSize.zero,0.3)
        
        
        
    }
    
    @objc func refresh(){
        
        showFriends()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func reloadTable(){
        
        friendsTableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notification_downloadDone), object: nil)
    }
    
    
    //MARK: - Function
    func showFriends(){
        
    
        ServiceManager.standard.refreshFirendLocation()
        refreshControl.endRefreshing()
        
    }
    
    func getDistance(lat:Double,lon:Double)->String{
        
        
        let location = CLLocation(latitude:lat,longitude:lon)
        guard let distance = locationManager.location?.distance(from: location) else{
            return ""
        }
        
        let km = MeterTurnKmString(distance)
        return km
        
    }
    
    func MeterTurnKmString(_ meter:Double)->String{
        
        let km = meter/1000
        
        if km.isNaN{
            return "0"
        }
        let kmStr = String(format: "%.1f",km)

        return"\(kmStr) km"
    }
    
}

//MARK:- UITableViewDelegate,UITableViewDataSource
extension FriendsViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ServiceManager.standard.friends.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell") as! FriendTableViewCell
        
        
        let friend = serviceManager.friends[indexPath.row]
        cell.titleLabel.text = friend.friendName
        cell.subDetailLabel.text = friend.lastUpdateDateTime
        
        
        let lat =  friend.lat
        let lon =  friend.lon
        let distance = getDistance(lat: lat, lon: lon)
        cell.detailLabel.text = distance
        
        
        if let photoURL = friend.photoURL{
            
            cell.photoImageView.loadImageWithNSCach(url: photoURL)
        }else{
            cell.photoImageView.image = UIImage(named: "user")
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.getDidSelectRowAt(row:indexPath.row)
        
    }
    
}
