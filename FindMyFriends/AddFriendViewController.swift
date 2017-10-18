//
//  AddFriendViewController.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/8/15.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class User:NSObject {
    var name:String
    var uid:String
    var status:String?
    var photoURL:String?
    
    init(name:String,uid:String,status:String?,photoURL:String?) {
        
        self.photoURL = photoURL
        self.name = name
        self.uid = uid
        self.status = status
    }
}

class AddFriendViewController: UIViewController {
    
    let serviceManager = ServiceManager.standard
    var searchUsers = [User]()
    var profileManager = ProfileManager.standard
    var sectionZeroRow = 1
    
    
    
    @IBOutlet weak var addFriendTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "搜尋好友"
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func searchUserWithEmail(email:String){
        
        
        guard let usrID = profileManager.userID else{
            return
        }
        
        
        let dict = [postServiceKey.account:email,
                    postServiceKey.userID:usrID]
        
        
        
        
        serviceManager.postToService(urlString:searchFriendURL ,dict: dict) { (error, result) in
            
            if error != nil{
                return
            }
            
            guard let myResult = result else{
                
                return
            }
            
            self.searchUsers.removeAll()
            if myResult[postServiceKey.result].boolValue{
                
                
                let arr = myResult[postServiceKey.searchResult].arrayValue
                
                for user in arr{
                    
                    let myUser = User(name: user[postServiceKey.userName].stringValue,
                                      uid: user[postServiceKey.userID].stringValue,
                                      status:user[postServiceKey.status].string,
                                      photoURL: user[postServiceKey.photoURL].string)
                    self.searchUsers.append(myUser)
                    
                }
            }else{
                
                SHLog(message: myResult[postServiceKey.errorCode].stringValue)
                
            }
            
            self.addFriendTableView.reloadData()
        }
        
    }
    
    
    func applyFriend(applidUid:String){
        
        
        guard let usrID = profileManager.userID,
            let userName = profileManager.userName else{
                return
        }
        
        let dict = [postServiceKey.applidID:applidUid,
                    postServiceKey.applyID:usrID,
                    postServiceKey.status:"等待同意",
                    postServiceKey.applyName:userName]
        
        
        
        serviceManager.postToService(urlString:insertApplyFriendURL, dict:dict) { (error, result) in
            
            if error != nil{
                return
            }
            
            guard let myResult = result else{
                
                return
            }
            
            
            if myResult[postServiceKey.result].boolValue{
                
                SHLog(message: "insertApplyFriend success")
                
            }else{
                
                if let errorCode =  myResult[postServiceKey.errorCode].string{
                    showSVProgressHUDError(error: errorCode, delay: 0.8)
                    
                }
                
                
            }
            
        }
        
    }
    
    
}
extension AddFriendViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0{
            
            return 200
        }
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            
            return sectionZeroRow
            
        }else{
            
            return searchUsers.count

        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        
        if indexPath.section == 0{
            
            let searchCell = tableView.dequeueReusableCell(withIdentifier: "SearchImageTableViewCell", for: indexPath) as! SearchImageTableViewCell
            searchCell.searchImageView?.image = UIImage(named:"search")
            searchCell.titleLabel.text = "趕快用Email，來加入好友吧！"
            tableView.separatorStyle = .none
            return searchCell
            
        }
        tableView.separatorStyle = .singleLine

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as! FriendTableViewCell
        if let url = searchUsers[indexPath.row].photoURL{
            
            cell.photoImageView.loadImageWithNSCach(url: url)
            
        }else{
            
            cell.photoImageView.image = UIImage(named:"user")
            
            
        }
        
        cell.titleLabel.text = searchUsers[indexPath.row].name
        cell.detailLabel.text = ""
        
        if let status = searchUsers[indexPath.row].status {
            
            
            cell.detailLabel.text = status
            
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            return
        }
        
        
        self.view.endEditing(true)
        
        if searchUsers[indexPath.row].status != nil{
            return
        }
        
        
        
        
        let alert = UIAlertController(title: "新增朋友", message: "確定要邀請 \(searchUsers[indexPath.row].name) 成為朋友？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "確認", style: .default) { (UIAlertAction) in
            self.applyFriend(applidUid:self.searchUsers[indexPath.row].uid)
            
        }
        let cancel = UIAlertAction(title:"取消", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
}



extension AddFriendViewController:UISearchBarDelegate{
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let text = searchBar.text{
            
            if serviceManager.isConnectService{
                
                searchUserWithEmail(email:text)
                
            }else{
                
                showSVProgressHUDError(error: isNotConnect, delay: 0.6)
            }
            
            
        }
        
        searchBar.resignFirstResponder()
        
    }
    
    
    
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        sectionZeroRow = 0
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        sectionZeroRow = 1
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = nil
        searchUsers.removeAll()
        addFriendTableView.reloadData()
        
        
    }
    
    
    
    
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if let text = searchBar.text{
    
            if text.isEmpty{
    
                    searchUsers.removeAll()
                    addFriendTableView.reloadData()
                
                }
    
//                }else{
//    
//                    if serviceManager.isConnectService{
//    
//                        searchUserWithEmail(email:text)
//    
//                    }else{
//    
//                        showSVProgressHUDError(error: isNotConnect, delay: 0.6)
//                    }
//                }
                
            }
        }
        
    
}
