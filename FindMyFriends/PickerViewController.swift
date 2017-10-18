//
//  PickerViewController.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/7/2.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

protocol PickerVCDelegate:class {
    
    func component()->Int
    func titleForRow()->[String]
    func getDidSelectRow(row:Int)
    func setSelectedRow()->Int?
    
    
    
}

class PickerViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    
    
    @IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var pickerContainerView: UIView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    var selectorRow:Int = 0
    weak var delegate:PickerVCDelegate? = nil
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        pickerContainerView.layer.cornerRadius = 5
        pickerContainerView.layer.shadowColor = UIColor.black.cgColor
        pickerContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        pickerContainerView.layer.shadowOpacity = 0.3

        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let row = delegate?.setSelectedRow() else{
            return
        }
        pickerView.selectRow(row, inComponent: 0, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    func display(parent:UIViewController){
        parent.addChildViewController(self)
        parent.view.addSubview(self.view)
        self.didMove(toParentViewController:parent)
        
    }
    
    func hiddle(){
        didMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         hiddle()
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        guard let  del = delegate else{
            return 0
        }
        
        return del.component()
    }
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        guard let  del = delegate else{
            return 0
        }
        return del.titleForRow().count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectorRow = row
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let  del = delegate else{
            return nil
        }
        let titleArray = del.titleForRow()
        
        return titleArray[row]
    }
    //MARK: - IBAction
        @IBAction func picterBtnAction(_ sender: UIButton) {
        delegate?.getDidSelectRow(row:selectorRow)
        hiddle()
    }

    
  
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
