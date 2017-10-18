//
//  LoginViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/22.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
import FBSDKLoginKit



class LoginViewController: UIViewController {
    
    @IBOutlet weak var nameTextFieldTop: NSLayoutConstraint!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var passWordTextFiled: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var choiceLoginSegmented: UISegmentedControl!
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var containerTextFieldsView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    let serviecManager = ServiceManager.standard
    let profileManager = ProfileManager.standard
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loginBtn.layer.cornerRadius = 5
        fbLoginBtn.layer.cornerRadius = 5
        containerTextFieldsView.setShadowView(0.2, CGSize.zero, 0.3)
        
        DispatchQueue.main.async {
            self.loginBtn.layer.cornerRadius = self.loginBtn.frame.height/2
            self.fbLoginBtn.layer.cornerRadius = self.fbLoginBtn.frame.height/2
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
    }
    
    
    
    func singInWithEmail(email:String,password:String){
        
        
        let dict = [postServiceKey.account:email,
                    postServiceKey.password:password]
        
        serviecManager.postToService(urlString:loginAndRegisterURL, dict:dict) { (error, result) in
            
            SVProgressHUD.dismiss()
            
            if let err = error {
                SHLog(message:err.localizedDescription)
                
                return
            }
            
            self.jsonToDictSetUserData(result:result)
            
        }
    }
    
    
    
    func validateEmail(email:String) -> Bool {
        
        
        if !email.contains("@") || !email.contains("."){
            return false
        }
        
        
        return true
    }
    
    func validatePassword(password:String) -> Bool {
        
        
        if password.characters.count<6{
            return false
        }
        
        
        return true
    }
    
    
    
    
    
    func register(name:String,email:String,password:String){
        
        let dict = [postServiceKey.name:name,
                    postServiceKey.account:email,
                    postServiceKey.password:password]
        
        
        
        
        
        serviecManager.postToService(urlString:loginAndRegisterURL, dict: dict) { (error, result) in
            
            SVProgressHUD.dismiss()
            
            if let err = error {
                
                self.showAlertWithError(message:err.localizedDescription)
                
                return
            }
            
            self.jsonToDictSetUserData(result:result)
        }
        
    }
    
    
    @IBAction func fbBtnAction(_ sender: Any) {
        let fbManager = FBSDKLoginManager()
        
        
        
        fbManager.logIn(withReadPermissions:["public_profile", "email"], from: self) { (result, error) in
            
            if error != nil{
                SHLog(message:error.debugDescription)
                
            }
            
            guard let myResult = result else {
                return
            }
            
            if myResult.isCancelled{
                
                SHLog(message:"isCancelled")
                
                
                
            }else{
                
                
                self.fetchProfile(userID:myResult.token.userID)
                
                
                
                
                
            }
        }
        
    }
    
    func fetchProfile(userID:String){
        
        
        
        let parameters = ["fields": "email, picture.type(large),name"]
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        
        
        FBSDKGraphRequest(graphPath:"me",parameters: parameters).start(completionHandler: {
            connection, result, error -> Void in
            
            if error != nil {
                SVProgressHUD.dismiss()
                
                SHLog(message:"longinerror =\(error.debugDescription)")
                
            } else {
                
                if let resultNew = result as? [String:Any],
                   let email = resultNew["email"] as? String,
                   let name = resultNew["name"] as? String {
                    
            
                    var photoURL:String?
                    if let picture = resultNew["picture"] as? NSDictionary,
                        let data = picture["data"] as? NSDictionary,
                        let url = data["url"] as? String {
                        photoURL = url
                    }
                    
                    self.fblogIn(email:email,password:userID,photoURL:photoURL,name:name)
                    
                    
                }
            }
        })
    }
    
    func fblogIn(email:String,password:String,photoURL:String?,name:String){
        
        var dict = [postServiceKey.account:email,
                    postServiceKey.password:password,
                    postServiceKey.name:name]
        
        if let myPhotoURL = photoURL{
            dict[postServiceKey.photoURL] = myPhotoURL
        }
        
        serviecManager.postToService(urlString:fbLogInURL,dict:dict) { (error, result) in
            
            SVProgressHUD.dismiss()
            
            if let err = error {
                SHLog(message:"fbloginError = \(err.localizedDescription)")
                
                return
            }
            
            
            self.jsonToDictSetUserData(result:result)
        }
        
    }
    
    
    func jsonToDictSetUserData(result:JSON?){
        
        if let myResult = result{
            
            if myResult[postServiceKey.result].boolValue{
                
                let userID = myResult[postServiceKey.userID].stringValue
                self.profileManager.setID(id:userID)
                self.profileManager.setUserName(name:myResult[postServiceKey.userName].stringValue)
                
                
                if myResult[postServiceKey.photoURL].string != nil{
                    
                    self.serviecManager.downloadUserPhotoWriteToCach(URLStr: myResult[postServiceKey.photoURL].stringValue,done: { (err) in
                        
                        self.goFirstPage()
                        
                    })
                    
                    
                }else{
                    
                    self.goFirstPage()
                }
                
                
            }else{
                
                self.showAlertWithError(message:myResult[postServiceKey.errorCode].stringValue)
                
            }
            
        }
        
        
    }
    
    
    func showAlertWithError(message:String){
        
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let ok =  UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
        
        
    }
    
    func goFirstPage(){
        
        
        
        DispatchQueue.main.async {
            
            if let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "FirstPage"){
                self.dismiss(animated: false, completion: nil)
                self.present(nextPage, animated: true)
            }
            
            
        }
        
        
    }
    
    
    
    
    @IBAction func loginBtnAction(_ sender: Any) {
        
        
        guard let email = emailTextField.text,
            let password = passWordTextFiled.text else{
                
                showAlertWithError(message:"請輸入完整")
                return
        }
        
        
        
        if email.isEmpty || password.isEmpty{
            showAlertWithError(message:"請輸入完整")
            return
        }
        
        if !validateEmail(email:email){
            showAlertWithError(message:"Email 格式錯誤")
            return
            
            
        }
        if !validatePassword(password: password){
            showAlertWithError(message:"密碼請輸入六位數")
            return
        }
        
        if !serviecManager.isConnectService{
            showSVProgressHUDError(error: isNotConnect, delay: 0.6)
        }
        
        
        
        
        
        SVProgressHUD.setDefaultMaskType(.black)
        
        
        
        // login
        if choiceLoginSegmented.selectedSegmentIndex == 1{
            
            SVProgressHUD.show()
            
            singInWithEmail(email:email,password:password)
            
            
            
        }else{
            
            
            let name = nameTextField.text
            
            
            if name == "" ||  name == nil{
                showAlertWithError(message:"The name is empty")
                
                return
            }
            
            SVProgressHUD.show()
            register(name:name!, email: email, password: password)
            
            
            
        }
    }
    
    
    
    
    @IBAction func chocieSegmentAction(_ sender: UISegmentedControl) {
        
        
        var nameTop:CGFloat
        var isHidden:Bool
        if sender.selectedSegmentIndex == 1{
            
            isHidden = true
            nameTop = -nameTextField.frame.height - 21
            nameTextField.alpha = 0
            
            
            
        }else{
            nameTop = 0
            isHidden = false
            nameTextField.alpha = 1
            
        }
        
        UIView.animate(withDuration:0.2, delay: 0, options:[.curveEaseInOut], animations: {
            self.nameTextFieldTop.constant = nameTop
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
            self.nameTextField.isHidden = isHidden
            
        })
    }
}
//MAKE: -UITextFieldDelegate
extension LoginViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    
}






