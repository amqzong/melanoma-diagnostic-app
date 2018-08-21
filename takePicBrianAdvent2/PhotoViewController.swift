//
//  PhotoViewController.swift
//  takePicBrianAdvent2
//
//  Created by Amanda Zong on 7/18/17.
//

import UIKit

import SwiftyDropbox

import Foundation

import CoreMedia

class PhotoViewController: UIViewController, DBRestClientDelegate {

    //initializes variables
    
    var takenPhoto: UIImage?
    var dbRestClient: DBRestClient!
    var uploadImageFileID: String?
    
    var filePath: String?
    var figureFilePath: String?
    
    var exposureDuration: CMTime!
    typealias exposureDurationTimeValue = String!
    typealias exposureDurationTimeScale = String!
    
    weak var timer: Timer?
    
    @IBOutlet weak var showDiagnosis: UILabel!

    @IBOutlet weak var loginStatus: UIButton!
    
    @IBOutlet weak var backtoViewController: UIButton!
    
    @IBOutlet weak var gotoFigureVC: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    //initialize Dropbox session
    
    func initDropboxRestClient() {
        dbRestClient = DBRestClient(session: DBSession.shared())
        dbRestClient.delegate = self as DBRestClientDelegate
    }
    
    //display taken photo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabel()

        if let availableImage = takenPhoto {
            imageView.image = availableImage
        }
        
        if DBSession.shared().isLinked() {
            initDropboxRestClient()
            loginStatus.setTitle("Disconnect", for: .normal)
        }
    }
    
    func setLabel() {
        self.showDiagnosis.textColor = UIColor.black
        self.showDiagnosis.font = UIFont(name: "Avenir-Light", size: 18.0)
    }

    // if back button is clicked, go back to View Controller
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func loginAction(_ sender: Any) {
        
        //connect to dropbox
        
        if !DBSession.shared().isLinked() {
            DBSession.shared().link(from: self)
            loginStatus.setTitle("Disconnect", for: .normal)
        }
            
        //disconnect from dropbox
            
        else {
            DBSession.shared().unlinkAll()
            loginStatus.setTitle("Connect", for: .normal)
        }
    }
    
    // if analyze button is clicked
    
    @IBAction func getDiagnosis(_ sender: Any) {
        
        //save taken photo to photo library
        
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, nil, nil)
        
        //if not connected to Dropbox, print error message to console
        
        if !DBSession.shared().isLinked() {
            print("You're not connected to Dropbox")
            return
        }
        
        let actionSheet = UIAlertController(title: "Upload file", message: "Select file to upload", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //if upload image is clicked
        
        let uploadImageFileAction = UIAlertAction(title: "Upload image", style: UIAlertActionStyle.default) { (action) -> Void in
            
            let exposureDurationTimeValue = String(self.exposureDuration.value)
            let exposureDurationTimeScale = String(self.exposureDuration.timescale)

            //create a unique image identifier called uploadImageFileID containing a unique string identifier and the exposure duration of hte image
            
            self.uploadImageFileID = NSUUID().uuidString + "ExposureTimeVal" + exposureDurationTimeValue + "Scale" + exposureDurationTimeScale
            let uploadImageFileName = self.uploadImageFileID! + ".jpg"
            let fileManager = FileManager.default
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(uploadImageFileName)
            print(paths)
            let imageData = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
            
            //create path to photo from app local directory
            
            fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
            let destinationPath = "/MelanomaDiagnosis"

            //upload image file to Dropbox
            
            self.dbRestClient.uploadFile(uploadImageFileName, toPath: destinationPath, withParentRev: nil, fromPath: paths)
            
            func restClient(_ client: DBRestClient!, uploadedFile destPath: String!, from srcPath: String!, metadata: DBMetadata!) {
                print("The file has been uploaded.")
                print(metadata.path)
            }
            
            func restClient(_ client: DBRestClient!, uploadFileFailedWithError error: NSError!) {
                print("File upload failed.")
                print(error.description)
            }
            
            //create diagnosis download name
            let downloadFileName = self.uploadImageFileID! + "Diagnosis" + ".txt"
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            self.filePath = url.appendingPathComponent(downloadFileName)?.path
            
            let sourcePath = "/MelanomaDiagnosis/" + downloadFileName
            
            self.showDiagnosis.text = "Uploading image..."

            self.backtoViewController.setTitle("Cancel", for: .normal)
            
            //set timer to check every interval whether the diagnosis file exists in Dropbox
            
            self.startTimer(sourcePath: sourcePath, filePath: self.filePath)
            
            //create figure download name
            
            let figureFileName = self.uploadImageFileID! + "Figure" + ".jpg"
            let figureSourcePath = "/MelanomaDiagnosis/" + figureFileName
            self.figureFilePath = url.appendingPathComponent(figureFileName)?.path
            
            //set timer to check every interval whether the figure file exists in Dropbox
            self.figureStartTimer(figureSourcePath: figureSourcePath, filePath: self.figureFilePath)

        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) -> Void in
            
        }
        
        actionSheet.addAction(uploadImageFileAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func restClient(_ client: DBRestClient!, loadedFile destPath: String!, contentType: String!, metadata: DBMetadata!) {
        print("The file \(metadata.filename) was downloaded. Content type: \(contentType)")
    }
    func restClient(client: DBRestClient!, loadFileFailedWithError error: NSError!) {
        print(error.description)
    }
    
    //check every specified interval for diagnosis file in Dropbox
    
    func startTimer(sourcePath: String!, filePath: String!) {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            do
            {
                self?.dbRestClient.loadFile(sourcePath, intoPath: filePath!)
                let contentString = try String(contentsOfFile:filePath!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                print(contentString)
                
                self?.showDiagnosis.text = "Finished analysis! QScore: " + contentString
                self?.stopTimer()
            }
            catch
            {
                self?.showDiagnosis.text = "Upload successful! Analyzing image..."
            }
        }
    }
    
    //go to Figure View Controller
    
    @IBAction func displayFigure(_ sender: Any) {

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: figureFilePath!) {
            let figure = UIImage(contentsOfFile: self.figureFilePath!)
            
            let figureVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "FigureVC") as! FigureViewController
            
            figureVC.downloadedFigure = figure
            
            DispatchQueue.main.async {
                self.present(figureVC, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func displayJan(_ sender: Any) {
        
        let JanVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "JanVC") as! JanViewController
        
        DispatchQueue.main.async {
            self.present(JanVC, animated: true, completion: nil)
        }
    }
    
    // check every specified interval whether figure exists in Dropbox
    
    func figureStartTimer(figureSourcePath: String!, filePath: String!) {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            do
            {
                self?.dbRestClient.loadFile(figureSourcePath, intoPath: filePath!)
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath!) {
                    self?.gotoFigureVC.setTitle("Click here to see biomarker figures!", for: .normal)
                    self?.stopTimer()
                }
            }
            catch
            {
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    // if appropriate, make sure to stop your timer in `deinit`
    
    deinit {
        stopTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
