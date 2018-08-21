//
//  ViewController.swift
//  takePicBrianAdvent2
//
//  Created by Amanda Zong on 7/18/17.

import UIKit
import AVFoundation

import SwiftyDropbox

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UIScrollViewDelegate {
    
    //initialize variables
    
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    
    var captureDevice:AVCaptureDevice!
    
    var takePhoto = false
    var deviceAuthorized: Bool  = false
    
    var videoView: UIView!
    
    var exposureDuration: CMTime!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCamera()
    }
    
    //sets captureDevice as TelephotoCamera
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInTelephotoCamera], mediaType: AVMediaTypeVideo, position: .back).devices {
            captureDevice = availableDevices.first
            beginSession()
        }
    }
    
    //initalizes video feed from camera
    
    func beginSession () {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
            do {
                try captureDevice?.lockForConfiguration()
                let zoomFactor:CGFloat = 2 //sets Zoom as 2x
                captureDevice?.videoZoomFactor = zoomFactor
                captureDevice?.unlockForConfiguration()
            } catch {
                //Catch error from lockForConfiguration
                print("Cannot zoom")
            }
        }
            
        catch {
            print(error.localizedDescription)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            self.previewLayer = previewLayer
            self.view.layer.addSublayer(self.previewLayer)
            self.previewLayer.frame = self.view.layer.frame
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value: kCVPixelFormatType_32BGRA)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.brianadvent.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
        }
    }
    
    //when camera button is pressed, boolean value takePhoto is set to true and the exposure duration of the photo is saved
    
    @IBAction func takePhoto(_ sender: Any) {
        takePhoto = true
        exposureDuration = captureDevice.exposureDuration
    }

    
    //when camera button is pressed, go to Photo View Controller
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        if takePhoto {
            takePhoto = false
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                DispatchQueue.main.async {
                    let photoVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
                    
                    //pass the variables image and exposure duration factor to the Photo View Controller
                    
                    photoVC.takenPhoto = image
                    photoVC.exposureDuration = self.exposureDuration
                    
                    DispatchQueue.main.async {
                        self.present(photoVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    //touch focus on object in image

    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        let touchPoint = touches.first!
        let screenSize = self.view.bounds.size
        let focusPoint = CGPoint(x: touchPoint.location(in: self.view).y / screenSize.height, y: 1.0 - touchPoint.location(in: self.view).x / screenSize.width)
        
        if let device = captureDevice {
            
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureFocusMode.autoFocus
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.autoExpose
                }
                device.unlockForConfiguration()
            }
            catch {
                
            }
        }
    }
    
    func stopCaptureSession () {
        self.captureSession.stopRunning()
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        prepareCamera()
    }

}

