//
//  ViewController.swift
//  CommonTool
//
//  Created by 程巍巍 on 3/14/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var yesrField: UITextField!
    @IBOutlet weak var monthField: UITextField!
    @IBOutlet weak var dayField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBAction func toSolar(sender: AnyObject) {
//        var date = NSDate(script: "\(yesrField.text.toInt()!)-\(monthField.text.toInt()!)-\(dayField.text.toInt()!)", format: "yyyy-MM-dd", lunar: true)!
        var date = NSDate(lunarYear: yesrField.text.toInt()!, month: monthField.text.toInt()!, day: dayField.text.toInt()!)
        resultLabel.text = "公历为： \(date!.lunar.components.SolarYear) 年 \(date!.lunar.components.SolarMonth) 月 \(date!.lunar.components.SolarDay) 日"
    }
    @IBAction func toLunar(sender: AnyObject) {
//      var date = NSDate(script: "\(yesrField.text.toInt()!)-\(monthField.text.toInt()!)-\(dayField.text.toInt()!)", format: "yyyy-MM-dd", lunar: false)!
        var date = NSDate(year: yesrField.text.toInt()!, month: monthField.text.toInt()!, day: dayField.text.toInt()!)
        resultLabel.text = "农历为： \(date!.lunar.components.LunarYearCN) \(date!.lunar.components.LunarMonthCN) \(date!.lunar.components.LunarDayCN)"
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBAction func snap(sender: AnyObject) {
        imageView.image = self.view.snap()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        yesrField.inputRuleType = UITextField.InputRuleType.Number
    }
    
    override func viewDidAppear(animated: Bool) {
//        self.view.makeToast("Toast", position: .bottomCenter, interval: 10)
//        self.view.showIndicator("loading")
//        self.view.backgroundColor = UIColor.color(script: "#FF00CC")
        
//        var button: UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
//        button.handle(events: UIControlEvents.TouchUpInside) { (sender, event) -> Void in
//            UIAlertView(title: nil, message: "Alert with colusure", cancelButtonTitle: "Cancel")
//                .add(button: "Confirm", handler: { (view, atIndex) -> Void in
//                    println("Message from alertview with colusure control")
//                }).add(button: "Yes", handler: { (view, atIndex) -> Void in
//                    println("\(atIndex)")
//                })
//                .show()
//        }
//        button.set(backgroundColor: UIColor.lightGrayColor())
//            .set(cornerRadius: 3.5)
//            .set(center: CGPointMake(100, 300))
//            .set(clipsToBounds: true)
//            .set(title: "Block Control", forState: UIControlState.Normal)
//            .sizeToFit()
//        self.view.set(backgroundColor: UIColor.color(script: "#afcb3d"))
//            .set(borderWidth: 5.5)
//            .set(borderColor: UIColor.greenColor())
//        self.view.addSubview(button)
        
//        var scrollView: UIScrollView = UIScrollView(frame: CGRectMake(100, 100, 100, 320))
//            .set(backgroundColor: UIColor.lightGrayColor())
//            .set(contentSize: CGSizeMake(100, 360))
//            .set(prefixView: UIView(frame: CGRectMake(0, 0, 100, 44))
//                .set(backgroundColor: UIColor.yellowColor()))
//            .set(suffixView:UIView(frame: CGRectMake(0, 0, 100, 44))
//                .set(backgroundColor: UIColor.purpleColor()))
//        
//        self.view.addSubview(scrollView)
        
        
    }
    
    func buttonAction(sender: UIButton){
        print("message from button action")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

