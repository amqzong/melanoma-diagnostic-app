//
//  ViewController.swift
//  testZoomer
//
//  Created by Amanda Zong on 8/8/17.
//  Copyright © 2017 Daniel Gareau. All rights reserved.
//

import UIKit

var scrollView: UIScrollView!
var imageView: UIImageView!



class JanViewController: UIViewController, UIScrollViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(image: UIImage(named: "4E620D20-7A96-46F8-93C9-A17CC1D67CC3ExposureTimeVal16666000Scale1000000000.jpg"))
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = imageView.bounds.size
        scrollView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 2.0
        scrollView.zoomScale = 1.0
        
        let button = UIButton(type: .system)
        
        button.frame = CGRect(x: 200, y: 700, width: 300, height: 40)
        button.setTitle("Back", for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        scrollView.addSubview(button)
        
        self.view?.addSubview(scrollView)
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func goBack(button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}

