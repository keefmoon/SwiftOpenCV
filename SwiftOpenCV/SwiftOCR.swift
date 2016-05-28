//
//  SwiftOCR.swift
//  SwiftOpenCV
//
//  Created by Lee Whitney on 10/28/14.
//  Copyright (c) 2014 WhitneyLand. All rights reserved.
//

import Foundation
import UIKit

class SwiftOCR {
    
    var image: UIImage
    var tesseract: Tesseract
    var characterBoxes : Array<CharBox>
    
    var groupedImage : UIImage
    var recognizedText: String
    
    convenience init(fromImagePath path:String) {
        
        let retrievedImage = UIImage(contentsOfFile: path)!
        self.init(fromImage: retrievedImage)
    }
    
    init(fromImage image:UIImage) {
        let fimage = image.fixOrientation()
        
//        let size = CGSizeMake(fimage.size.width, fimage.size.height)
        
//        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
//        fimage.drawInRect(CGRectMake(0, 0, size.width, size.height))
//        self.image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext();

        self.image = fimage
        
        tesseract = Tesseract(language: "eng")
        tesseract.setVariableValue("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", forKey: "tessedit_char_whitelist")
        tesseract.image = image
        characterBoxes = Array<CharBox>()
         groupedImage = image
        recognizedText = ""
        NSLog("%d",image.imageOrientation.rawValue);
    }
    
    //Recognize function
    func recognize() {
        
         characterBoxes = Array<CharBox>()
        
        let uImage = CImage(image: image);
        
        let channels = uImage.channels;
        
        let classifier1 = NSBundle.mainBundle().pathForResource("trained_classifierNM1", ofType: "xml")
//        let classifier2 = NSBundle.mainBundle().pathForResource("trained_classifierNM2", ofType: "xml")
        
        let erFilter1 = ExtremeRegionFilter.createERFilterNM1(classifier1, c: 8, x: 0.00015, y: 0.13, f: 0.2, a: true, scale: 0.1);
//        let erFilter2 = ExtremeRegionFilter.createERFilterNM2(classifier2, andX: 0.5);
        
        var regions = Array<ExtremeRegionStat>();
        
        for channel in channels {
            var region = ExtremeRegionStat()
            
            region = erFilter1.run(channel as! UIImage);
            
            regions.append(region);
        }
        
        groupedImage = ExtremeRegionStat.groupImage(uImage, withRegions: regions);
        
        tesseract.recognize();
    
        let words = tesseract.getConfidenceByWord;
        
        var texts = Array<String>();
        
        for word in words {
            let dict = word as! Dictionary<String, AnyObject>
            let text = dict["text"] as! String
            let confidence = dict["confidence"] as! Float
            let box = dict["boundingbox"] as! NSValue
            if((text.utf16.count < 2 || confidence < 51) || (text.utf16.count < 4 && confidence < 60)){
                continue
            }
            
            let rect = box.CGRectValue()
            characterBoxes.append(CharBox(text: text, rect: rect))
            texts.append(text)
        }
        
        var str : String = ""
        
        for (idx, item) in texts.enumerate() {
            str += item
            if idx < texts.count-1 {
                str += " "
            }
        }
        
        recognizedText = str
    }
}