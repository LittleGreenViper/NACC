/*
 © Copyright 2022, Little Green Viper Software Development LLC
 
 LICENSE:
 
 MIT License
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
 modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import UIKit

/* ###################################################################################################################################### */
// MARK: - Bundle Extension -
/* ###################################################################################################################################### */
/**
 This extension adds a few simple accessors for some of the more common bundle items.
 */
extension Bundle {
    /* ################################################################## */
    /**
     If there is a copyright site URI, it is returned here as a String. It may be nil.
     */
    var siteURIAsString: String? { object(forInfoDictionaryKey: "InfoScreenCopyrightSiteURL") as? String }

    /* ################################################################## */
    /**
     If there is a privacy site URI, it is returned here as a String. It may be nil.
     */
    var privacyURIAsString: String? { object(forInfoDictionaryKey: "InfoScreenPrivacySiteURL") as? String }
    
    /* ################################################################## */
    /**
     If there is a copyright site URI, it is returned here as a URL. It may be nil.
     */
    var siteURI: URL? { URL(string: siteURIAsString ?? "") }

    /* ################################################################## */
    /**
     If there is a privacy site URI, it is returned here as a URL. It may be nil.
     */
    var privacyURI: URL? { URL(string: privacyURIAsString ?? "") }

    /* ################################################################## */
    /**
     This come straight from here: https://stackoverflow.com/a/51241158/879365
     
     This returns the highest-res version of the app icon, as an image. Nil, if unavailable.
     */
    var appIcon: UIImage? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last else { return nil }
        
        return UIImage.assetOrSystemImage(name: lastIcon)
    }
}

/* ###################################################################################################################################### */
// MARK: - UIViewController Extension -
/* ###################################################################################################################################### */
/**
 Flags for various display modes.
 */
extension UIViewController {
    /* ################################################################## */
    /**
     Returns true, if we are in Dark Mode.
     */
    var isDarkMode: Bool { .dark == traitCollection.userInterfaceStyle }
    
    /* ################################################################## */
    /**
     Returns true, if we are in High Contrast Mode.
     */
    var isHighContrastMode: Bool { UIAccessibility.isDarkerSystemColorsEnabled }
    
    /* ################################################################## */
    /**
     Returns true, if we are in Reduced Transparency Mode.
     */
    var isReducedTransparencyMode: Bool { UIAccessibility.isReduceTransparencyEnabled }
}

/* ###################################################################################################################################### */
// MARK: - UIView Extension -
/* ###################################################################################################################################### */
/**
 We add a couple of ways to deal with first responders.
 */
extension UIView {
    /* ################################################################## */
    /**
     This creates a constraint, locking the view to a given aspect ratio.
     - parameter aspectRatio: The aspect ratio. It is W/H, so numbers less than 1.0 are wider than tall, and numbers greater than 1.0 are taller than wide.
     - returns: An inactive constraint, locking this view to the given aspect ratio.
     */
    func autoLayoutAspectConstraint(aspectRatio inAspect: CGFloat) -> NSLayoutConstraint? {
        guard 0.0 < inAspect else { return nil }
        
        return NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: inAspect, constant: 0)
    }
}

/* ###################################################################################################################################### */
// MARK: - UIImage Extension -
/* ###################################################################################################################################### */
/**
 This adds some simple image manipulation.
 */
extension UIImage {
    /* ################################################################## */
    /**
     This is a "cascading" image fetcher. It first, ses if there is an asset with the name given, then, it looks in the SFSymbols, finally, returning the SFSymbols.nosign, if none found.
     
     - parameter name: The name of the resource.
     
     - returns: A new image. May be nil, if none found.
     */
    class func assetOrSystemImage(name inName: String) -> UIImage? { UIImage(named: inName) ?? UIImage(systemName: inName) ?? UIImage(systemName: "nosign") }
    
    /* ################################################################## */
    /**
     This returns the RGB color (as a UIColor) of the pixel in the image, at the given point. It is restricted to 32-bit (RGBA/8-bit pixel) values.
     This was inspired by several of the answers [in this StackOverflow Question](https://stackoverflow.com/questions/25146557/how-do-i-get-the-color-of-a-pixel-in-a-uiimage-with-swift).
     **NOTE:** This is unlikely to be highly performant!
     
     - parameter at: The point in the image to sample (NOTE: Must be within image bounds, or nil is returned).
     - returns: A UIColor (or nil).
     */
    func getRGBColorOfThePixel(at inPoint: CGPoint) -> UIColor? {
        guard (0..<size.width).contains(inPoint.x),
              (0..<size.height).contains(inPoint.y)
        else { return nil }

        // We draw the image into a context, in order to be sure that we are accessing image data in our required format (RGBA).
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(at: .zero)
        let imageData = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = imageData?.cgImage,
              let pixelData = cgImage.dataProvider?.data
        else { return nil }
        
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let bytesPerPixel = (cgImage.bitsPerPixel + 7) / 8
        let pixelByteOffset: Int = (cgImage.bytesPerRow * Int(inPoint.y)) + (Int(inPoint.x) * bytesPerPixel)
        let divisor = CGFloat(255.0)
        let r = CGFloat(data[pixelByteOffset]) / divisor
        let g = CGFloat(data[pixelByteOffset + 1]) / divisor
        let b = CGFloat(data[pixelByteOffset + 2]) / divisor
        let a = CGFloat(data[pixelByteOffset + 3]) / divisor

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
