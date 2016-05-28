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
        
        let alert = UIAlertController(title: "Please choose an option", message: nil, preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Take Picture", style: .Default) { [weak self] action in
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.allowsEditing = false
            self?.presentViewController(imagePicker, animated: true, completion: nil)
        }
        let photoLibraryAction = UIAlertAction(title: "Choose Picture", style: .Default) { [weak self] action in
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = false
            self?.presentViewController(imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func onRecognizeTapped(sender: AnyObject) {
        
        guard let selectedImage = selectedImage else {
            
            let alert = UIAlertController(title: "SwiftOCR", message: "Please select image", preferredStyle: .Alert)
            let cancel = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(cancel)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let progressHud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHud.labelText = "Detecting..."
        progressHud.mode = MBProgressHUDModeIndeterminate
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            let ocr = SwiftOCR(fromImage: selectedImage)
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
