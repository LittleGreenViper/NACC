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
import LGV_UICleantime

/* ###################################################################################################################################### */
// MARK: - Main App Delegate -
/* ###################################################################################################################################### */
/**
 This is a simple application delegate that allows the app to start up.
 */
@UIApplicationMain
class NACCAppSceneDelegate: UIResponder {
    /* ################################################################## */
    /**
     Required Window Property
     */
    var window: UIWindow?
    
    /* ################################################################## */
    /**
     Quick accessor for the app delegate, cast to this class.
     */
    static var appDelegateInstance: NACCAppSceneDelegate?
    
    /* ################################################################## */
    /**
     The name of our default scene configuration.
     */
    static private let _sceneConfigurationName = "NACCDefaultConfiguration"

    /* ################################################################## */
    /**
     This will contain the original prefs, if the app was started from a URL (so we reset).
     */
    var originalPrefs: (cleanDate: Date, lastSelectedTabIndex: NACCTabBarController.TabIndexes)?

    /* ################################################################## */
    /**
     This will contain the date for the selectors.
     */
    var cleandate: Date?
    
    /* ################################################################## */
    /**
     This is used to allow a tab to be selected from the URL.
     */
    var selectedTab: NACCTabBarController.TabIndexes = .keytagArray
    
    /* ################################################################## */
    /**
     This will contain the textual report, for the calculation.
     */
    var report: String = ""
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension NACCAppSceneDelegate {
    /* ################################################################## */
    /**
     Returns the interface (not device) orientation
     */
    var windowInterfaceOrientation: UIInterfaceOrientation? { UIApplication.shared.windows.first?.windowScene?.interfaceOrientation }
    
    /* ################################################################## */
    /**
     Easy access to our navigation controller.
     */
    var navigationController: UINavigationController? {
        var ret: UINavigationController?
        
        if let temp = window?.rootViewController as? UINavigationController {
            ret = temp
        } else {
            for scene in UIApplication.shared.connectedScenes where .unattached != scene.activationState && .background != scene.activationState {
                if let temp = ((scene as? UIWindowScene)?.delegate as? UIWindowSceneDelegate)?.window??.rootViewController as? UINavigationController {
                    ret = temp
                    break
                }
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is the initial view controller.
     */
    var initialViewController: NACCInitialViewController? {
        if let navigationController = navigationController,
           let viewController = navigationController.viewControllers[0] as? NACCInitialViewController {
            return viewController
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: UIWindowSceneDelegate Conformance
/* ###################################################################################################################################### */
extension NACCAppSceneDelegate: UIWindowSceneDelegate {
    /* ################################################################## */
    /**
     Called when the app is opened via a URL.
     
     We parse the URL, and set a couple of instance variables, if the URL parameters are correct.
     
     The URL scheme is thus:
     
     **nacc://**_[YYYY-MM-DD[**/**N]]_

     _YYYY-MM-DD_ is a standard [ISO 8601 calendar date](https://en.wikipedia.org/wiki/ISO_8601#Calendar_dates) (For example, September first, 1980, is 1980-09-01).
     
     _N_ is the numerical index of a tab:
     
        - 0 is Keytag Array
        - 1 is Keytag Strip
        - 2 is Medallions

     - parameter inScene: The scene instance (ignored).
     - parameter openURLContexts: The Opening URL contexts (as a set).
     */
    func scene(_ inScene: UIScene, openURLContexts inURLContexts: Set<UIOpenURLContext>) {
        #if DEBUG
            print("\n#### Scene Opening Via URL Contexts.\n####\n")
        #endif
        guard !inURLContexts.isEmpty else { return }
        
        for context in inURLContexts {
            let url = context.url

            #if DEBUG
                print("\n#### Scene was opened from this URI: \(url)\n####\n")
            #endif
            if let host = url.host,
               !host.isEmpty {
                originalPrefs = (cleanDate: NACCPersistentPrefs().cleanDate, lastSelectedTabIndex: NACCTabBarController.TabIndexes(rawValue: NACCPersistentPrefs().lastSelectedTabIndex) ?? .keytagArray) // Store for replacement, later
                
                let pathComponents = url.pathComponents.compactMap { ("/" != $0) && !$0.isEmpty ? $0 : nil }
                
                selectedTab = NACCTabBarController.TabIndexes(rawValue: Int(String(pathComponents.isEmpty ? "0" : pathComponents[0])) ?? 0) ?? .keytagArray

                #if DEBUG
                    print("\tThe URL has this date: \(host), and wants this tab: \(selectedTab.rawValue)")
                #endif

                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let date = dateFormatter.date(from: host) {
                    cleandate = date
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when the app is opened via a URL (and launched).
     
     We simply call the other handler, and use that parse the URI.
     
     - parameter inScene: The scene instance (ignored).
     - parameter willConnectTo: The session being connected (also ignored).
     - parameter options: This contains the options, among which, is the URL context.
     */
    func scene(_ inScene: UIScene, willConnectTo: UISceneSession, options inConnectionOptions: UIScene.ConnectionOptions) {
        #if DEBUG
            print("\n#### Scene Connecting Via URL.\n####\n")
        #endif
        scene(inScene, openURLContexts: inConnectionOptions.urlContexts)
    }
    
    /* ################################################################## */
    /**
     Called when the app is about to come into the foreground.
     
     We use this to set the app to the initial screen, and also, to check if we have a URL specified.
     
     - parameter: The scene instance (ignored).
     */
    func sceneWillEnterForeground(_: UIScene) {
        #if DEBUG
            print("\n#### Scene Entering Foreground.\n####\n")
        #endif
        navigationController?.popToRootViewController(animated: false)
        if let initialViewController = initialViewController {
            if nil == cleandate,
               let originals = originalPrefs {
                originalPrefs = nil
                let date = originals.cleanDate
                NACCPersistentPrefs().lastSelectedTabIndex = originals.lastSelectedTabIndex.rawValue
                initialViewController.setDate(date)
            } else if let date = cleandate {
                cleandate = nil
                #if DEBUG
                    print("Setting date: \(date), and tab: \(selectedTab.rawValue)")
                #endif
                initialViewController.setDate(date, tabIndex: selectedTab)
            }
        }
        
        cleandate = nil // Take off and nuke the site from orbit. It's the only way to be sure...
    }
}

/* ###################################################################################################################################### */
// MARK: UIApplicationDelegate Conformance
/* ###################################################################################################################################### */
extension NACCAppSceneDelegate: UIApplicationDelegate {
    /* ################################################################## */
    /**
     Called when the application starts.
     
     - parameters: Ignored
     - returns: true, always.
    */
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Self.appDelegateInstance = self
        return true
    }

    /* ################################################################## */
    /**
     - parameter: The application instance (ignored).
     - parameter configurationForConnecting:
     - parameter options:
     - returns: The scene configuration.
     */
    func application(_: UIApplication, configurationForConnecting inConnectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: Self._sceneConfigurationName, sessionRole: inConnectingSceneSession.role)
    }
}
