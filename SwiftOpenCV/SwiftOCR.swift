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
    
    var tesseract: Tesseract
    let backgroundQueue = dispatch_get_global_queue(0, 0)
    
    init() {
        
        tesseract = Tesseract(language: "eng")
        tesseract.setVariableValue("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", forKey: "tessedit_char_whitelist")
    }
    
    func prepare(image: UIImage, completionHandler: UIImage -> Void) {
        
        dispatch_async(backgroundQueue) {
            
            let fixedImage = image.fixOrientation()
            let cImage = CImage(image: fixedImage)
            
            let classifier1 = NSBundle.mainBundle().pathForResource("trained_classifierNM1", ofType: "xml")
            let erFilter1 = ExtremeRegionFilter.createERFilterNM1(classifier1, c: 8, x: 0.00015, y: 0.13, f: 0.2, a: true, scale: 0.1)
            
            let regions: [ExtremeRegionStat] = cImage.channels.map { erFilter1.run($0 as! UIImage) }
            
            let groupedImage = ExtremeRegionStat.groupImage(cImage, withRegions: regions)
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(groupedImage)
            }
        }
    }
    
    func recognize(forImage image: UIImage, completionHandler: ([RecognizedTextBox] -> Void)) {
        
        tesseract.image = image
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            self.tesseract.recognize()
            
            let words = self.tesseract.getConfidenceByWord as! [[String: AnyObject]]
            
            let textBoxes: [RecognizedTextBox] = words.map {
                
                let text = $0["text"] as! String
                let confidence = $0["confidence"] as! Float
                let frameValue = $0["boundingbox"] as! NSValue
                let frame = frameValue.CGRectValue()
                
                return RecognizedTextBox(text: text, confidence: confidence, frame: frame)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(textBoxes)
            }
        }
    }
}