//
//  UpdateUserDataViewController.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/8/17.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import SVProgressHUD

class UpdateUserDataViewController: UIViewController {
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    
    
    let profileManager = ProfileManager.standard
    let serviceManager = ServiceManager.standard
    var userSelectImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.text = profileManager.userName!
        
        
        navigationItem.title = "修改資料"
        
        if let usrImage = profileManager.userPhotoURL{
            
            userPhotoImageView.image = UIImage(imageName:usrImage, search: .cachesDirectory)
            
        }else{
            
            userPhotoImageView.image = UIImage(named:"user")
            
        }
        userPhotoImageView.layer.cornerRadius = 40
        
        let save = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(updateUserDateToService))
        navigationItem.rightBarButtonItem = save
        
        
    }
    

    
    @objc func updateUserDateToService(){
        
        guard let name = userNameTextField.text,
            !name.isEmpty else {
                
               showSVProgressHUDError(error: "請輸入暱稱", delay: 0.8)
                
                return
                
        }
        
        if !serviceManager.isConnectService{
            
             showSVProgressHUDError(error: isNotConnect, delay: 0.8)
            
            return
            
        }
        
        
        
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.black)
        var dict = [postServiceKey.userName:name,postServiceKey.userID:profileManager.userID!]
        
        if let image = userSelectImage{
            
            
            guard let imageData = UIImageJPEGRepresentation(image,0.8),
                let userID = ProfileManager.standard.userID else{
                    return
            }
            
            
            image.writeToFile(imageName:"profile_\(userID).jpg", search: .cachesDirectory)
            profileManager.setPhotoURL(url: "profile_\(userID).jpg")
            let  base64Str =  imageData.base64EncodedString(options: .lineLength64Characters)
            dict["userPhoto"] = base64Str
        }
        
        
        
        profileManager.setUserName(name:name)
        
        serviceManager.postToService(urlString:updateUserDataURL,dict:dict) { (error, result) in
            SVProgressHUD.dismiss()
            self.navigationController?.popViewController(animated: true)
            
        }
        
    }
    
    @IBAction func pickImageTapAction(_ sender: Any) {
        
        let alert = UIAlertController(title:"",message: "選擇", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "相機", style: .default) { (UIAlertAction) in
            self.launchImagePicker(source: .camera)
        }
        let album = UIAlertAction(title: "相簿", style: .default) { (UIAlertAction) in
            self.launchImagePicker(source:.savedPhotosAlbum)
        }
        
        let canacel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(album)
        alert.addAction(canacel)
        
        
        present(alert, animated: true, completion:nil)
        
        
    
        
    }
    
    func launchImagePicker(source:UIImagePickerControllerSourceType){
        
        if !UIImagePickerController.isSourceTypeAvailable(source){
            
            return
            
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if source == .camera{
            imagePicker.sourceType = source
            imagePicker.mediaTypes = ["public.image"]
            
            
        }else{
            
            imagePicker.sourceType = source
            imagePicker.allowsEditing = true
            
            
            
        }
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
    
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
//MARK: - UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension UpdateUserDataViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
    
        if let originImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            userSelectImage = originImage
            
            
            
        }
        if let editImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            
            userSelectImage = editImage
            
            
        }
        
        
        if userSelectImage != nil{
            
            userSelectImage = userSelectImage?.resizeImage(maxLength:200)
            userPhotoImageView.image = userSelectImage
            
        }
        picker.dismiss(animated: true, completion: nil)
        
    }

}










