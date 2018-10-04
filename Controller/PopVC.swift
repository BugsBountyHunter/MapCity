//
//  PopVC.swift
//  MapCity
//
//  Created by AHMED SR on 10/4/18.
//  Copyright © 2018 AHMED SR. All rights reserved.
//

import UIKit

class PopVC: UIViewController  , UIGestureRecognizerDelegate{
    //MARK: outletes
    @IBOutlet weak var popImageView: UIImageView!
    var passedImage:UIImage!
    func initData(forImage image:UIImage){
     self.passedImage = image
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      popImageView.image = passedImage
       addDoubleTap()
    }
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    @objc func screenWasDoubleTap(){
      dismiss(animated: true, completion: nil)
    }
    
}
