//
//  TimerViewController.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/29.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

protocol TimerVCDelegate:class {
    func getTimerStatus(status:TimerStatus)
}

class TimerViewController: UIViewController {
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var buttomView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    let timerStandard = MyTimerManager.standard
    
    weak var delegate:TimerVCDelegate? = nil
    var timerStatus = TimerStatus.none {
        didSet{
            delegate?.getTimerStatus(status:timerStatus)
        }
    }
    
    @IBOutlet weak var startButtonTrailing: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(changeTime), name: NSNotification.Name(rawValue:notifyName_updateTime), object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(changeDistance), name: NSNotification.Name(rawValue:notifyName_updateDistance), object: nil)
        
        
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:notifyName_updateTime), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue:notifyName_updateDistance), object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK:- IBAction
    @IBAction func startButtonAction(_ sender: Any) {
        
        
        if timerStatus == .none{
            timerStatus = .start
            timerStandard.startTimer()
            UIView.animate(withDuration:0.3) {
                 
                
                self.startButtonTrailing.constant = self.startButton.frame.width/2
                self.view.layoutIfNeeded()
                self.startButton.setTitle("暫停", for: .normal)
            }
        }else if  timerStatus == .start{
            timerStatus = .pause
            timerStandard.stopTimer()
            self.startButton.setTitle("繼續", for: .normal)
            
        }else if timerStatus == .pause{
            timerStatus = .start
            timerStandard.startTimer()
            self.startButton.setTitle("暫停", for: .normal)
            
        }
        
        
    }
    @IBAction func endButtonAction(_ sender: Any) {
        timerStatus = .none
        timerStandard.resetTimer()
        
        
        UIView.animate(withDuration:0.3) {
            self.startButtonTrailing.constant = 0
            self.view.layoutIfNeeded()
            self.startButton.setTitle("開始", for: .normal)
        }
        
    }
    
    //MARK:- Function
    
    @objc func changeDistance(){
        distanceLabel.text = MeterTurnKmString(timerStandard.distance)
        
    }
    
    @objc func changeTime(){
        
        
        timeLabel.text =  timerStandard.timeString
        
    }
    
    func MeterTurnKmString(_ meter:Int)->String{
        let mesterDouble = Double(meter)
        
        let km = mesterDouble/1000
        
           return "\(km.roundTo(places: 2))"
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
extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        
        return (self * divisor).rounded() / divisor
    }
}

