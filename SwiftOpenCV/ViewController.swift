//
//  ViewController.swift
//  SwiftOpenCV
//
//  Created by Lee Whitney on 10/28/14.
//  Copyright (c) 2014 WhitneyLand. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedImage : UIImage!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTakePictureTapped(sender: AnyObject) {
        
        let sheet: UIActionSheet = UIActionSheet();
        let title: String = "Please choose an option";
        sheet.title  = title;
        sheet.delegate = self;
        sheet.addButtonWithTitle("Choose Picture");
        sheet.addButtonWithTitle("Take Picture");
        sheet.addButtonWithTitle("Cancel");
        sheet.cancelButtonIndex = 2;
        sheet.showInView(self.view);
    }
    
    func actionSheet(sheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        switch buttonIndex{
            
        case 0:
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.presentViewController(imagePicker, animated: true, completion: nil)
            break;
        case 1:
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.presentViewController(imagePicker, animated: true, completion: nil)
            break;
        default:
            break;
        }
    }
    
    
    @IBAction func onDetectTapped(sender: AnyObject) {
        
        let progressHud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHud.labelText = "Detecting..."
        progressHud.mode = MBProgressHUDModeIndeterminate
        
        let ocr = SwiftOCR(fromImage: selectedImage)
        ocr.recognize()
        
        imageView.image = ocr.groupedImage
        
        progressHud.hide(true);
    }
    
    @IBAction func onRecognizeTapped(sender: AnyObject) {
        
        if((self.selectedImage) != nil){
            let progressHud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            progressHud.labelText = "Detecting..."
            progressHud.mode = MBProgressHUDModeIndeterminate
            
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                let ocr = SwiftOCR(fromImage: self.selectedImage)
                ocr.recognize()
                
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.imageView.image = ocr.groupedImage
                    
                    progressHud.hide(true);
                    
                    let dprogressHud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    dprogressHud.labelText = "Recognizing..."
                    dprogressHud.mode = MBProgressHUDModeIndeterminate
                    
                    let text = ocr.recognizedText
                    
                    self.performSegueWithIdentifier("ShowRecognition", sender: text);
                    
                    dprogressHud.hide(true)
                })
            })
        }else {
            let alert = UIAlertView(title: "SwiftOCR", message: "Please select image", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        selectedImage = image;
        picker.dismissViewControllerAnimated(true, completion: nil);
        imageView.image = selectedImage;
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc =  segue.destinationViewController as! DetailViewController
        vc.recognizedText = sender as! String
    }
}

