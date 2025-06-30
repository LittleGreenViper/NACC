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

/* ###################################################################################################################################### */
// MARK: - About Screen View Controller -
/* ###################################################################################################################################### */
/**
 This screen displays the information about the app.
 */
class NACCAboutViewController: NACCBaseViewController {
    /* ################################################################## */
    /**
     This is the size of the icon for the logo button.
     */
    private static let _iconSizeInDisplayUnits = CGFloat(100)

    /* ################################################################################################################################## */
    // MARK: Instance IBOutlet Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This displays the app icon.
     It is a button, that links to the main Web site.
     */
    @IBOutlet weak var appIconButton: UIButton?

    /* ################################################################## */
    /**
     This displays the app version.
     Selecting it brings up an alert that includes the build number.
     */
    @IBOutlet weak var versionLabelButton: UIButton?

    /* ################################################################## */
    /**
     This displays a button that links to the app privacy site.
     */
    @IBOutlet weak var privacyButton: UIButton?

    /* ################################################################## */
    /**
     This displays the corporate Web site link.
     */
    @IBOutlet weak var lgvButton: UIButton?
    
    /* ################################################################## */
    /**
     This displays the help text.
     */
    @IBOutlet weak var helpView: UITextView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension NACCAboutViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has completed loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        if let aboutLogo = UIImage(named: "AboutLogo")?.withRenderingMode(.alwaysOriginal).resized(toMaximumSize: Self._iconSizeInDisplayUnits) {
            self.appIconButton?.setImage(aboutLogo, for: .normal)
        }
        self.appIconButton?.imageView?.contentMode = .scaleAspectFit
        self.versionLabelButton?.setTitle(String(format: "SLUG-APP-INFO-VERSION-FORMAT-SMALL".localizedVariant, Bundle.main.appVersionString), for: .normal)
        self.helpView?.text = "SLUG-APP-INFO-TEXT".localizedVariant
        
        self.lgvButton?.setTitle((self.lgvButton?.title(for: .normal) ?? "ERROR").localizedVariant, for: .normal)
        self.lgvButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        self.lgvButton?.titleLabel?.minimumScaleFactor = 0.5
        self.privacyButton?.setTitle((self.privacyButton?.title(for: .normal) ?? "ERROR").localizedVariant, for: .normal)
        self.privacyButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        self.privacyButton?.titleLabel?.minimumScaleFactor = 0.5
        
        self.appIconButton?.accessibilityLabel = "SLUG-ACC-APPICON-BUTTON".localizedVariant
        self.versionLabelButton?.accessibilityLabel = "SLUG-ACC-VERSION-BUTTON".localizedVariant
        self.privacyButton?.accessibilityLabel = "SLUG-ACC-PRIVACY-BUTTON".localizedVariant
        self.lgvButton?.accessibilityLabel = "SLUG-ACC-LGV-BUTTON".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension NACCAboutViewController {
    /* ################################################################## */
    /**
     Called when the version label button is tapped.
     - parameter: ignored.
     */
    @IBAction func displayVersionInfo(_: UIButton) {
        let displayString = String(format: "SLUG-APP-INFO-VERSION-FORMAT".localizedVariant,
                                   Bundle.main.appDisplayName,
                                   Bundle.main.appVersionString,
                                   Bundle.main.appVersionBuildString)
        
        let alertController = UIAlertController(title: displayString, message: nil, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "SLUG-OK-BUTTON-TEXT".localizedVariant, style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    /* ################################################################## */
    /**
     Called when the privacy button is hit.
     - parameter: ignored
     */
    @IBAction func privacyButtonHit(_: Any) {
        guard let uri = Bundle.main.privacyURI else { return }
        UIApplication.shared.open(uri, options: [:], completionHandler: nil)
    }

    /* ################################################################## */
    /**
     Called when the app icon button is hit.
     - parameter: ignored
     */
    @IBAction func appIconButtonHit(_: Any) {
        guard let uri = Bundle.main.helpURI else { return }
        UIApplication.shared.open(uri, options: [:], completionHandler: nil)
    }

    /* ################################################################## */
    /**
     Called when the button to visit the main site is hit.
     - parameter: ignored
     */
    @IBAction func lgvButtonHit(_: Any) {
        guard let uri = Bundle.main.siteURI else { return }
        UIApplication.shared.open(uri, options: [:], completionHandler: nil)
    }
}
