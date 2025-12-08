/*
© Copyright 2012-2025, Little Green Viper Software Development LLC

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
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox
import LGV_Cleantime
import LGV_UICleantime

/* ###################################################################################################################################### */
// MARK: - Attributed String Extension -
/* ###################################################################################################################################### */
/**
 This extension allows us to get the displayed height and width (given a full-sized canvas -so no wrapping or truncating) of an attributed string.
 */
fileprivate extension NSAttributedString {
    /* ################################################################## */
    /**
     - returns: The height required to display the string, in display units.
     */
    var _stringHeight: CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.height)
    }
    
    /* ################################################################## */
    /**
     - returns: The width required to display the string, in display units.
     */
    var _stringWidth: CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.width)
    }
}

/* ###################################################################################################################################### */
// MARK: - Initial Screen Print Renderer -
/* ###################################################################################################################################### */
/**
 This class is a print renderer for the screens. It will create a formatted report, with the tag/medallion display, underneath. It is just 1 page.
 */
class NACCPagePrintRenderer: UIPrintPageRenderer {
    /* ################################################################## */
    /**
     We will reduce the font to a level that will display in the area provided.
     This is where we start.
     */
    let startingFontSize: CGFloat = 40

    /* ################################################################## */
    /**
     This holds the string report, at the top of the page.
     */
    var cleantimeReport: String

    /* ################################################################## */
    /**
     This will hold the cleantime tag or medallion image, to be printed below the report.
     */
    var cleantimeImage: UIImage?
    
    /* ################################################################## */
    /**
     Initializer with the string and the image.
     
     - parameter inReportString: The string, containing the cleantime report.
     - parameter inTagImage: The tag/medallion image displayed.
     */
    init(report inReportString: String, image inTagImage: UIImage?) {
        self.cleantimeReport = inReportString
        self.cleantimeImage = inTagImage
        
        super.init()

        self.headerHeight = 0
        self.footerHeight = 0
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Override Calculated Instance Properties
/* ###################################################################################################################################### */
extension NACCPagePrintRenderer {
    /* ################################################################## */
    /**
     - returns: 1 (always)
     */
    override var numberOfPages: Int { 1 }
}

/* ###################################################################################################################################### */
// MARK: Base Class Override Methods
/* ###################################################################################################################################### */
extension NACCPagePrintRenderer {
    /* ################################################################## */
    /**
     This will draw out the report page, with the report in the top quarter, and the image in the bottom.
     
     - parameter at: The page number (ignored).
     - parameter inContentRect: The content destination context rect.
     */
    override func drawContentForPage(at: Int, in inContentRect: CGRect) {
        let reportRect = CGRect(origin: inContentRect.origin, size: CGSize(width: inContentRect.size.width, height: inContentRect.size.height * 0.25))
        let imageRect = CGRect(origin: CGPoint(x: inContentRect.origin.x, y: inContentRect.origin.y + inContentRect.size.height * 0.25),
                               size: CGSize(width: inContentRect.size.width, height: inContentRect.size.height * 0.75))
        self.drawReport(in: reportRect)
        
        guard !imageRect.isEmpty,
              let imageToDraw = self.cleantimeImage?.resized(toMaximumSize: min(imageRect.size.height, imageRect.size.width))
        else { return }
        
        Self.drawImage(imageToDraw, in: imageRect)
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension NACCPagePrintRenderer {
    /* ################################################################## */
    /**
     Draw the text report.
     
     - parameter inContentRect: This is the display rect.
     */
    func drawReport(in inContentRect: CGRect) {
        let cRect = inContentRect.insetBy(dx: 4, dy: 4)

        var fontSize = self.startingFontSize
        var width: CGFloat = 0
        var height: CGFloat = 0
        var descriptionString: NSAttributedString! = nil
        
        // What we do here, is continuously sample the display rect of the string, until we find a font size that fits the display.
        repeat {
            var attributes: [NSAttributedString.Key: Any] = [:]
            attributes[NSAttributedString.Key.backgroundColor] = UIColor.clear
            attributes[NSAttributedString.Key.foregroundColor] = UIColor.black
            attributes[NSAttributedString.Key.font] = UIFont.italicSystemFont(ofSize: fontSize)
            
            descriptionString = NSAttributedString(string: self.cleantimeReport, attributes: attributes)

            width = descriptionString._stringWidth
            height = descriptionString._stringHeight
            
            fontSize -= 0.25
        } while (width > cRect.size.width) || (height > cRect.size.height)

        if nil != descriptionString {
            descriptionString.draw(at: cRect.origin)
        }
    }
    
    /* ################################################################## */
    /**
     Draw the image
     
     - parameter inImage: The image to be drawn.
     - parameter inContentRect: This is the display rect.
     */
    static func drawImage(_ inImage: UIImage, in inContentRect: CGRect) {
        let cRect = inContentRect.insetBy(dx: (inContentRect.size.width - inImage.size.width) / 2,
                                          dy: (inContentRect.size.height - inImage.size.height) / 2)
        inImage.draw(at: cRect.origin)
    }
}
