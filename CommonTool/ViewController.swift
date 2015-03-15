//
//  ViewController.swift
//  CommonTool
//
//  Created by 程巍巍 on 3/14/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        
        var scrollView: UIScrollView = UIScrollView(frame: CGRectMake(100, 100, 100, 480))
            .set(backgroundColor: UIColor.lightGrayColor())
            .set(contentSize: CGSizeMake(100, 960))
            .set(prefixView: UIView(frame: CGRectMake(0, 0, 100, 44))
                .set(backgroundColor: UIColor.yellowColor()))
        
        self.view.addSubview(scrollView)
    }
    
    func buttonAction(sender: UIButton){
        print("message from button action")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

