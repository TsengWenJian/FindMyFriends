//
//  SettingTableViewController.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/25.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class SetUpTableViewController: UITableViewController {
    let profiles = ProfileManager.standard
    var UpdateTypeDictKey = [String]()
    var updateTypeDictValue = [Double]()
    var recordArray = [LocationRecord]()
    var sectionIsDisplay = [false,false,false,false,false,false]
      
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UpdateTypeDictKey = profiles.backgroudUpdataBodyTitle
        updateTypeDictValue = profiles.backgroudUpdateBodyValue
        
        let manager = MyLocationRecordsManager(.LocationRecord)
        recordArray = manager.getLocatoinRecord(cond: nil, order: "id desc")
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(receivedPushNotice),
                                               name: NSNotification.Name(rawValue:notifyName_downloadFriends),
                                               object: nil)
        
        
        
    }
    
    @objc func receivedPushNotice(){
        
        tableView.reloadData()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:notifyName_downloadFriends), object: nil)
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return profiles.sectionTitleArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        
        if section == 0{
            
            return profiles.managerFriendTitle.count
            
            
        }else if section == 2{
            if sectionIsDisplay[section]{
                
                return profiles.updateFrequencyBodyTitle.count
            }
            
            
            
        }else if section == 3{
            if sectionIsDisplay[section]{
                return profiles.backgroudUpdataBodyTitle.count
            }
            
        }else if section == 4{
            
            if sectionIsDisplay[section]{
                
                //Show no record
                if recordArray.count == 0{
                    return 1
                }
                return recordArray.count
            }
        }else if section == 5{
            return 1
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if indexPath.section == 0{
            
            
            
            if indexPath.row == 0{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ManagerFriendsTableViewCell") as! ManagerFriendsTableViewCell
                let badge = UIApplication.shared.applicationIconBadgeNumber
                cell.titleLabel.text =  profiles.managerFriendTitle[indexPath.row]
                
                if badge == 0{
                    cell.badgeContainerView.isHidden = true
                    
                }else{
                    
                    cell.badgeContainerView.isHidden = false
                    cell.badgeLabel.text = badge == 0 ? "":"\(badge)"
                    
                    
                }
                
                return cell
                
                
            }else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "BackgroundBodyCell") as! BackgroundUpdateBodyTableViewCell
                cell.titleLabel.text =  profiles.managerFriendTitle[indexPath.row]
                cell.selectTypeLabel.text = ""
                return cell
                
            }
            
            
            
            
            
            
        }else if indexPath.section == 2{
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BackgroundBodyCell") as! BackgroundUpdateBodyTableViewCell
            
            
            
            cell.titleLabel.text = profiles.updateFrequencyBodyTitle[indexPath.row]
            cell.selectTypeLabel.text = ""
            
            
            if profiles.updateFrequency == 0 && indexPath.row == 0{
                
                
                cell.selectTypeLabel.text = "✓"
            }else if indexPath.row == 1{
                
                
                if profiles.updateFrequency != 0{
                    cell.selectTypeLabel.text = String(profiles.updateFrequency) + "(S)"
                }
                
                
            }
            
            
            
            return cell
            
        }else if indexPath.section == 3{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BackgroundBodyCell") as! BackgroundUpdateBodyTableViewCell
            
            
            
            cell.titleLabel.text = UpdateTypeDictKey[indexPath.row]
            cell.selectTypeLabel.text = ""
            
            
            if  updateTypeDictValue[indexPath.row] == profiles.desiredAccuracy {
                cell.selectTypeLabel.text = "✓"
            }
            
            
            
            return cell
            
            
        }else if indexPath.section == 4{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyLocationRecordCell") as!LocationRecordTableViewCell
            
            if recordArray.count == 0{
                
                cell.titleLabel.text = "尚未紀錄軌跡"
                cell.detailLabel.text = ""
                
            }else{
                cell.titleLabel.text = recordArray[indexPath.row].startTime
                cell.detailLabel.text = "🕐\(recordArray[indexPath.row].totalTime)"
                
                
            }
            
            
            return cell
            
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
            cell.textLabel?.text = "登出"
            
            
            return cell
        }
        
        
    }
    
    @objc func pushUpdatePage(){
        
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "UpdateUserDataViewController") as! UpdateUserDataViewController
        
        
        
        navigationController?.pushViewController(nextPage, animated: true)
        
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileUserTableViewCell") as! ProfileUserTableViewCell
            cell.userNameLabel.text = profiles.userName
            
            
            
            
            if let photoString = profiles.userPhotoURL {
                
                cell.userPhotoImageView.image = UIImage(imageName:photoString, search: .cachesDirectory)
                
            }else{
                cell.userPhotoImageView.image =  UIImage(named: "user")
                
                
                
            }
            
            
            cell.updateBtn.addTarget(self, action: #selector(pushUpdatePage), for: .touchUpInside)
            
            return cell.contentView
            
            
            
        }else if section == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShareingCell") as! ShareingLocationTableViewCell
            cell.titleLabel.text = profiles.sectionTitleArray[section]
            cell.shareingSwitch.setOn(profiles.userisShareing, animated: false)
            cell.shareingSwitch.addTarget(self, action: #selector(changeSwitch(sender:)), for: .valueChanged)
            
            return cell.contentView
            
            
        }else if section == 5{
            
            return nil
            
            
            
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell") as!BasicHeaderTableViewCell
            cell.titleLabel.text = profiles.sectionTitleArray[section]
            cell.rightButton.addTarget(self, action:#selector(displaySection(sender:)), for: .touchUpInside)
            cell.rightButton.tag = section + 1000
            cell.rightLabel.text = "➘"
            
            if sectionIsDisplay[section]{
                cell.rightLabel.text = "➚"
                
                
            }
            
    
            return cell.contentView
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0{
            return 80
            
        }else if section == 5{
            return 1
        }
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if indexPath.section == 0{
            
            if indexPath.row == 0{
                
                let nextPage = storyboard?.instantiateViewController(withIdentifier: "ManageFriendsTableViewController") as! ManageFriendsTableViewController
                navigationController?.pushViewController(nextPage, animated: true)
                
            }else{
                let nextPage = storyboard?.instantiateViewController(withIdentifier: "AddFriendViewController") as! AddFriendViewController
                navigationController?.pushViewController(nextPage, animated: true)
                
                
                
            }
            
            
            
            
        }else if indexPath.section == 2{
            
            if indexPath.row == 0{
                
                
                profiles.updateFrequency = 0
                tableView.reloadData()
                
            }else{
                var pickerVC = PickerViewController()
                pickerVC = storyboard?.instantiateViewController(withIdentifier: "PickerViewController") as!PickerViewController
                pickerVC.delegate = self
                pickerVC.display(parent: self)
            }
            
            
            
            
        } else if  indexPath.section == 3{
            
            
            profiles.desiredAccuracy = updateTypeDictValue[indexPath.row]
            
            tableView.reloadData()
            
        }else if indexPath.section == 4 {
            
            if  recordArray.count != 0{
                
                let nextPage = storyboard?.instantiateViewController(withIdentifier: "ShowLocationRecordViewController") as!ShowLocationRecordViewController
                nextPage.startTime = recordArray[indexPath.row].startTime
                navigationController?.pushViewController(nextPage, animated: true)
                
            }else{
                
                let alertVC = UIAlertController(title: "開始紀錄", message: "需要前往並開始軌跡記錄嗎?", preferredStyle: .alert)
                let action = UIAlertAction(title: "前往", style: .default, handler: { (UIAlertAction) in
                    self.profiles.gotoBeginRecord = true
                    self.navigationController?.popViewController(animated: true)
                    
                })
                
                let cancel = UIAlertAction(title: "取消", style: .default, handler:nil)
                alertVC.addAction(cancel)
                alertVC.addAction(action)
                present(alertVC, animated: true, completion: nil)
                
                
                
            }
            
            
        }else{
            
            navigationController?.popToViewController(self, animated: false)
            
            if ServiceManager.standard.isConnectService{
                
                if let userId = profiles.userID {
                    
                    ServiceManager.standard.updateDeviceToken(userID:userId,deviceToken:" ")
                    
                }
                
                profiles.setUserDataNil()
               
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:notifyName_logOut), object: nil)
                    
                }

                
            }else{
                showSVProgressHUDError(error: isNotConnect, delay: 0.6)
                
            }

        }
        
        
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        if indexPath.section == 4 && recordArray.count != 0{
            return true
        }
        
        return false
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            guard let id = recordArray[indexPath.row].id else{
                return
            }
            
            
            let cond = "id = '\(id)'"
            let manager = MyLocationRecordsManager(.LocationRecord)
            manager.deleteRecord(cond:cond)
            
            let startTime = recordArray[indexPath.row].startTime
            let detailCond = "start_time = '\(startTime)'"
            let detailManager = MyLocationRecordsManager(.DetailRecord)
            
            detailManager.deleteRecord(cond:detailCond)
            
            recordArray.remove(at: indexPath.row)
            tableView.reloadData()
            
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }
    
    //MARK:- Fuction
    @objc func changeSwitch(sender:UISwitch){
        if sender.isOn{
            
            profiles.userisShareing = true
        }else{
            profiles.userisShareing = false
        }
        
        
    }
    
    @objc func displaySection(sender:UIButton){
        
        
        let section = sender.tag - 1000
        sectionIsDisplay[section] = !sectionIsDisplay[section]
        self.tableView.reloadSections(IndexSet(integer:section), with:.automatic)
        
        
        
        
        
        
    }
    
    
    
}

//MARK:- PickerVCDelegate
extension SetUpTableViewController:PickerVCDelegate{
    
    func getDidSelectRow(row:Int){
        if let row =  Int(profiles.autoRefreshSecord[row]){
            profiles.updateFrequency = row
            
        }
        tableView.reloadData()
    }
    
    func component() -> Int {
        return 1
    }
    
    func titleForRow() -> [String] {
        return profiles.autoRefreshSecord
    }
    func setSelectedRow()->Int?{
        let secord = String(profiles.updateFrequency)
        
        if  let index = profiles.autoRefreshSecord.index(of:secord){
            return index
        }
        
        return nil
    }
    
    
    
    
    
}
