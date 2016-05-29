//
//  UIImageView+GeometryConversion.swift
//  SwiftOpenCV
//
//  Created by Keith Moon on 28/05/2016.
//  Copyright © 2016 WhitneyLand. All rights reserved.
//

import UIKit

enum ImageViewConversionError: ErrorType {
    case NoImage
}

extension UIImageView {
    
    func convertToViewPoint(fromImagePoint point: CGPoint) throws -> CGPoint {
        
        guard let image = image else { throw ImageViewConversionError.NoImage }
        
        let imageSize = image.size
        let viewSize = bounds.size
        
        let ratioX = viewSize.width / imageSize.width
        let ratioY = viewSize.height / imageSize.height
        
        var convertedPoint = point
        
        switch contentMode {
            
        case .ScaleToFill, .Redraw:
            convertedPoint.x = point.x * ratioX
            convertedPoint.y = point.y * ratioY
            
        case .ScaleAspectFit:
            let scale = min(ratioX, ratioY)
            convertedPoint.x = point.x * scale + (viewSize.width - imageSize.width * scale) / 2
            convertedPoint.y = point.y * scale + (viewSize.height - imageSize.height * scale) / 2
            
        case .ScaleAspectFill:
            let scale = max(ratioX, ratioY)
            convertedPoint.x = point.x * scale + (viewSize.width - imageSize.width * scale) / 2
            convertedPoint.y = point.y * scale + (viewSize.height - imageSize.height * scale) / 2
            
        case .Center:
            convertedPoint.x = point.x + viewSize.width / 2 - imageSize.width / 2
            convertedPoint.y = point.y + viewSize.height / 2 - imageSize.height / 2
            
        case .Top:
            convertedPoint.x = point.x + viewSize.width / 2 - imageSize.width / 2
            
        case .Bottom:
            convertedPoint.x = point.x + viewSize.width / 2 - imageSize.width / 2
            convertedPoint.y = point.y + viewSize.height - imageSize.height
         
        case .Left:
            convertedPoint.y = point.y + viewSize.height / 2 - imageSize.height / 2
         
        case .Right:
//.           convertedPoint.x = point.x + viewSize.width - imageSize.width
            convertedPoint.y = point.y + viewSize.height / 2 - imageSize.height / 2
            
        case .TopRight:
            convertedPoint.x = point.x + viewSize.width - imageSize.width
            
        case .BottomLeft:
            convertedPoint.y = point.y + viewSize.height - imageSize.height
            
        case .BottomRight:
            convertedPoint.x = point.x + viewSize.width - imageSize.width
            convertedPoint.y = point.y + viewSize.height - imageSize.height
            
        case .TopLeft:
            break
        }
        
        return convertedPoint
    }
    
    func convertToViewRect(fromImageRect rect: CGRect) throws -> CGRect {
        
        let imageTopLeft = rect.origin
        let imageBottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))
        
        let viewTopLeft = try convertToViewPoint(fromImagePoint: imageTopLeft)
        let viewBottomRight = try convertToViewPoint(fromImagePoint: imageBottomRight)
        
        var convertedRect = rect
        convertedRect.origin = viewTopLeft
        convertedRect.size = CGSizeMake(abs(viewBottomRight.x - viewTopLeft.x),
                                        abs(viewBottomRight.y - viewTopLeft.y))
        return convertedRect
    }
    
    func convertToImagePoint(fromViewPoint point: CGPoint) throws -> CGPoint {
     
        guard let image = image else { throw ImageViewConversionError.NoImage }
        
        let imageSize = image.size
        let viewSize = bounds.size
        
        let ratioX = viewSize.width / imageSize.width
        let ratioY = viewSize.height / imageSize.height
        
        var convertedPoint = point
        
        switch contentMode {
            
        case .ScaleToFill, .Redraw:
            convertedPoint.x = point.x / ratioX
            convertedPoint.y = point.y / ratioY
            
        case .ScaleAspectFit:
            let scale = min(ratioX, ratioY)
            convertedPoint.x = (point.x - (viewSize.width - imageSize.width  * scale) / 2) / scale
            convertedPoint.y = (point.y - (viewSize.height - imageSize.height  * scale) / 2) / scale
            
        case .ScaleAspectFill:
            let scale = max(ratioX, ratioY)
            convertedPoint.x = (point.x - (viewSize.width - imageSize.width  * scale) / 2) / scale
            convertedPoint.y = (point.y - (viewSize.height - imageSize.height  * scale) / 2) / scale
            
        case .Center:
            convertedPoint.x = point.x - (viewSize.width - imageSize.width) / 2
            convertedPoint.y = point.y - (viewSize.height - imageSize.height) / 2
            
        case .Top:
            convertedPoint.x = point.x - (viewSize.width - imageSize.width) / 2
            
        case .Bottom:
            convertedPoint.x = point.x - (viewSize.width - imageSize.width) / 2
            convertedPoint.y = point.y - viewSize.height - imageSize.height
            
        case .Left:
            convertedPoint.y = point.y - (viewSize.height - imageSize.height) / 2
            
        case .Right:
            convertedPoint.x = point.x - (viewSize.width - imageSize.width)
            convertedPoint.y = point.y - (viewSize.height - imageSize.height) / 2
            
        case .TopRight:
            convertedPoint.x = point.x - viewSize.width - imageSize.width
            
        case .BottomLeft:
            convertedPoint.y = point.y - viewSize.height - imageSize.height
            
        case .BottomRight:
            convertedPoint.x = point.x - viewSize.width - imageSize.width
            convertedPoint.y = point.y - viewSize.height - imageSize.height
            
        case .TopLeft:
            break
        }
        
        return convertedPoint
    }
    
    func convertToImageRect(fromViewRect rect: CGRect) throws -> CGRect {
        
        let imageTopLeft = rect.origin
        let imageBottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))
        
        let viewTopLeft = try convertToImagePoint(fromViewPoint: imageTopLeft)
        let viewBottomRight = try convertToImagePoint(fromViewPoint: imageBottomRight)
        
        var convertedRect = rect
        convertedRect.origin = viewTopLeft
        convertedRect.size = CGSizeMake(abs(viewBottomRight.x - viewTopLeft.x),
                                        abs(viewBottomRight.y - viewTopLeft.y))
        return convertedRect
    }
}
