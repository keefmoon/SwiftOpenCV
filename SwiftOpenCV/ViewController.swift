//
//  ViewController.swift
//  SwiftOpenCV
//
//  Created by Lee Whitney on 10/28/14.
//  Copyright (c) 2014 WhitneyLand. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum Segue: String {
        case ShowRecognition
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedImage : UIImage?
    
    // MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc =  segue.destinationViewController as! DetailViewController
        vc.recognizedText = sender as! String
    }
    
    // MARK: Actions
    
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
    
    @IBAction func onRecognizeTapped(sender: AnyObject) {
        
        guard let selectedImage = selectedImage else {
            
            let alert = UIAlertController(title: "SwiftOCR", message: "Please select image", preferredStyle: .Alert)
            let cancel = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let progressHud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHud.labelText = "Detecting..."
        progressHud.mode = MBProgressHUDModeIndeterminate
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            let ocr = SwiftOCR(fromImage: self.selectedImage)
            ocr.recognize()
            
            dispatch_sync(dispatch_get_main_queue()) {
                self.imageView.image = ocr.groupedImage
                
                progressHud.hide(true);
                
                let dprogressHud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                dprogressHud.labelText = "Recognizing..."
                dprogressHud.mode = MBProgressHUDModeIndeterminate
                
                let text = ocr.recognizedText
                
                self.performSegueWithIdentifier(Segue.ShowRecognition.rawValue, sender: text)
                
                dprogressHud.hide(true)
            }
        }
    }
}

// MARK: - UIActionSheetDelegate

extension ViewController: UIActionSheetDelegate {
    
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
}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        guard let choosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        selectedImage = choosenImage
        picker.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = choosenImage
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
