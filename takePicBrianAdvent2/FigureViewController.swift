//  FigureViewController.swift
//  Created by Amanda Zong on 8/3/17.
//  Credits: Camera App Swift Tutorial by Brian Advent (https://www.youtube.com/watch?v=Zv4cJf5qdu0)
//  Description: Displays any figures corresponding to skin lesion features, such such as pigmented networks and 
//  color variation.

import Foundation

class FigureViewController: UIViewController, UIScrollViewDelegate {
    
    var downloadedFigure: UIImage?
    var scrollView: UIScrollView!
    
    var delayContentTouches: Bool?
    
    @IBOutlet weak var figureView: UIImageView!
    
    // display figure
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let availableImage = downloadedFigure {
            figureView.image = availableImage
            UIImageWriteToSavedPhotosAlbum(availableImage, self, nil, nil)
        }
        
        scrollView = UIScrollView(frame: figureView.bounds)
        scrollView.contentSize = figureView.bounds.size
        scrollView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        scrollView.delegate = self
        
        scrollView.addSubview(figureView)
        view.addSubview(scrollView)
        
        scrollView.delaysContentTouches = false
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        
        let button = UIButton(type: .system)
        
        button.frame = CGRect(x: 20, y: 10, width: 60, height: 40)
        button.setTitle("Back", for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        scrollView.addSubview(button)
        
        self.view?.addSubview(scrollView)

    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return figureView
    }
    
    // go back to Photo View Controller
    
    
    func goBack(sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
}
