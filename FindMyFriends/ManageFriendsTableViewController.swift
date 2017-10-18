//
//  ManageFriendsTableViewController.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/8/15.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import SVProgressHUD
class ManageFriendsTableViewController: UITableViewController {
    
    
    let sectionTitle = ["所有好友","被邀請"]
    var applidFriend = [User]()
    var friendsArr = [User]()
    let serviceManager = ServiceManager.standard
    let profileManager = ProfileManager.standard
    var userID = String()
    var userName =  String()
    var sectionIsDisplay = [true,true]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let myUserID =  profileManager.userID,
            let myUserName = profileManager.userName else{
                let nextPage  = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                nextPage.showDetailViewController(nextPage, sender: self)
                return
        }
        
        
        userID = myUserID
        userName = myUserName
        navigationItem.title = "好友列表"
        getAllFriend()
        
        NotificationCenter.default.addObserver(self, selector:#selector(getAllFriend), name: NSNotification.Name(rawValue: "downloadFriends"), object: nil)
        
        
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "downloadFriends"), object: nil)
        
        SHLog(message: "---------ManageFriendsTableViewController---------deinit")
    }
    
    
    @objc func getAllFriend(){
        
        
        if serviceManager.isConnectService{
            getFriend()
            getApplidFriend()
        }else{
            
            showSVProgressHUDError(error: isNotConnect, delay: 0.8)
        }
        
        
         tableView.refreshControl?.endRefreshing()
        
        
    }
    
    func getApplidFriend(){
        
        
        
        let dict = [postServiceKey.action:"applidID",postServiceKey.userID:userID]
        
        serviceManager.postToService(urlString:selectApplyFriendURL, dict: dict) { (error, result) in
            if error != nil{
                return
            }
            
            guard let myResult = result else{
                
                return
            }
            
            
            var myApplidFriend = [User]()
            if myResult[postServiceKey.result].boolValue{
                
                
                let arr = myResult[postServiceKey.searchResult].arrayValue
                
                for user in arr{
                    
                    let myUser = User(name: user[postServiceKey.userName].stringValue,
                                      uid: user[postServiceKey.userID].stringValue,
                                      status: nil,
                                      photoURL:user[postServiceKey.photoURL].string)
                    myApplidFriend.append(myUser)
                    
                }
                
                
            }else{
                
                SHLog(message:myResult[postServiceKey.errorCode].stringValue)
                
            }
            
            self.applidFriend = myApplidFriend
            
            UIApplication.shared.applicationIconBadgeNumber = self.applidFriend.count
            self.tableView.reloadData()
        }
        
        
        
    }
    
    func getFriend(){
        
        
        let dict = [postServiceKey.userID:userID]
        
        
        serviceManager.postToService(urlString:selectFriendDataURL ,dict: dict) { (error, result) in
            if error != nil{
                return
            }
            
            guard let myResult = result else{
                
                return
            }
            
            var myFriendsArr = [User]()
            
            if myResult[postServiceKey.result].boolValue{
                
                let arr = myResult[postServiceKey.friends].arrayValue
                
                for user in arr{
                    
                    let myUser = User(name: user[postServiceKey.userName].stringValue,
                                      uid: user[postServiceKey.userID].stringValue,
                                      status: nil,
                                      photoURL:user[postServiceKey.photoURL].string)
                    
                    myFriendsArr.append(myUser)
                    
                }
            }else{
                
                SHLog(message:myResult[postServiceKey.errorCode].stringValue)
                
            }

            
            self.friendsArr = myFriendsArr
            
            
            self.tableView.reloadData()
        }
        
        
    }
    
    @IBAction func refeshFriend(_ sender: Any) {
        
        getAllFriend()
       
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sectionTitle.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            
            return sectionIsDisplay[section] ?friendsArr.count:0
            
            
            
        }else if section == 1{
            
             return sectionIsDisplay[section] ?applidFriend.count:0
        }
        
        return 0
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "BasicCell") as! BasicHeaderTableViewCell
        headerCell.titleLabel.text = sectionTitle[section]
        headerCell.rightButton.addTarget(self,action:#selector(displaySection), for:.touchUpInside)
        headerCell.rightButton.tag = 1000 + section
        
        return headerCell.contentView
    }
    
    @objc func displaySection(_ sender:UIButton){
        let section = sender.tag - 1000
        sectionIsDisplay[section] = !sectionIsDisplay[section]
        let index = IndexSet(integer:section)
        tableView.reloadSections(index, with: .automatic)
        
        
        
        
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as! FriendTableViewCell
        if indexPath.section == 0{
            cell.titleLabel.text = friendsArr[indexPath.row].name
            
            
            if let url = friendsArr[indexPath.row].photoURL{
                
                cell.photoImageView.loadImageWithNSCach(url: url)
                
            }else{
                
                cell.photoImageView.image = UIImage(named:"user")
                
                
            }
            
            
        }else if indexPath.section == 1{
            
            
            
            
            cell.titleLabel.text = applidFriend[indexPath.row].name
            
            if let url = applidFriend[indexPath.row].photoURL{
                
                cell.photoImageView.loadImageWithNSCach(url: url)
                
            }else{
                
                cell.photoImageView.image = UIImage(named:"user")
                
            }
            
        }
        
        return cell
    }
    
    
    
    
    
    func updateStatus(applyUid:String,action:String){
        
        
        
        if !serviceManager.isConnectService{
            
            showSVProgressHUDError(error: isNotConnect, delay: 0.8)
            
            return
            
        }
        
              
        
        let dict = [postServiceKey.applyID:applyUid,
                    postServiceKey.applidID:userID,
                    postServiceKey.action:action,
                    postServiceKey.applyName:userName]
        
        
        
        serviceManager.postToService(urlString: updateApplyFriendStatusURL, dict:dict) { (error, result) in
            
         

            if error != nil{
                return
            }
            
            guard let myResoult = result else{
                
                return
            }
            
            
            if myResoult[postServiceKey.result].boolValue{
                
                self.getAllFriend()
                
            }
            
            
        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            let alert = UIAlertController(title: "新增", message: "同意和 \(applidFriend[indexPath.row].name) 成為好友嗎?", preferredStyle: .alert)
            let agree = UIAlertAction(title: "同意", style: .default) { (UIAlertAction) in
                
                self.updateStatus(applyUid:self.applidFriend[indexPath.row].uid, action: "agree")
                
                
            }
            
            let disagree = UIAlertAction(title: "不同意", style: .default) { (UIAlertAction) in
                
                self.updateStatus(applyUid:self.applidFriend[indexPath.row].uid, action: "disagree")
                
                
                
            }
            
            let cancel = UIAlertAction(title:"取消", style: .cancel, handler: nil)
            alert.addAction(agree)
            alert.addAction(disagree)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
        }
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    func deleteFriend(friendID:String){
        
        if !serviceManager.isConnectService {
              showSVProgressHUDError(error: isNotConnect, delay: 0.8)
            return
        }
        
        let dict = [postServiceKey.userID:userID,postServiceKey.friendID:friendID]
        
        
        serviceManager.postToService(urlString:deleteFriendURL ,dict: dict) { (error, result) in
            
            
            if error != nil{
                
                return
            }
            
            guard let myResult = result else{
              
                return
            }
            
            
            if myResult[postServiceKey.result].boolValue{
                
                self.getFriend()
                
            }else{
                 SHLog(message:myResult[postServiceKey.errorCode])
            }
            
            
        }
        
        
    }
    
    
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if  indexPath.section == 1{
            return  false
        }
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            
            let alert = UIAlertController(title: "刪除", message: "確定要刪除 \(friendsArr[indexPath.row].name) 這位好友嗎?", preferredStyle: .alert)
            let agree = UIAlertAction(title: "確定", style: .default) { (UIAlertAction) in
                
                self.deleteFriend(friendID:self.friendsArr[indexPath.row].uid)
                
                
            }
            
            
            let cancel = UIAlertAction(title:"取消", style: .cancel, handler: nil)
            alert.addAction(agree)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
            
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
