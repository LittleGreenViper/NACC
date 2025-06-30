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
// MARK: - Main App Delegate -
/* ###################################################################################################################################### */
/**
 This is a simple application delegate that allows the app to start up.
 */
@UIApplicationMain
class NACCAppSceneDelegate: UIResponder {
    /* ################################################################## */
    /**
     Used for when we store the original state of the app, when called from a URI.
     */
    typealias OriginalPrefsTuple = (cleanDate: Date, lastSelectedTabIndex: NACCTabBarController.TabIndexes)
    
    /* ################################################################## */
    /**
     Required Window Property
     */
    var window: UIWindow?
    
    /* ################################################################## */
    /**
     Quick accessor for the app delegate, cast to this class.
     */
    private static var _appDelegateInstance: NACCAppSceneDelegate?
    
    /* ################################################################## */
    /**
     The name of our default scene configuration.
     */
    private static let _sceneConfigurationName = "NACCDefaultConfiguration"

    /* ################################################################## */
    /**
     This will contain the original prefs, if the app was started from a URL (so we reset).
     */
    private static var _originalPrefs: OriginalPrefsTuple?

    /* ################################################################## */
    /**
     This is a special flag, for use when opened by a URI. If true, then the app always starts at the initial screen.
     */
    private var _resetScreen = false

    /* ################################################################## */
    /**
     This is used to allow a tab to be selected from the URL.
     */
    private var _selectedTabFromURI: NACCTabBarController.TabIndexes?
    
    /* ################################################################## */
    /**
     This will contain the date for the selectors.
     */
    private var _date: Date?

    /* ################################################################## */
    /**
     This will contain the textual report, for the calculation.
     */
    private var _report: String = ""
    
    /* ################################################################## */
    /**
     The ID for the "Display Cleantime" activity.
     */
    static let displayCleantimeID = "DisplayCleantime"
    
    /* ################################################################## */
    /**
     The ID for the "Display Cleantime" activity data field.
     */
    static let cleanDateUserDataID = "cleanDate"
    
    /* ################################################################## */
    /**
     The ID for the "Selected Tab" activity data field.
     */
    static let selectedTabUserDataID = "selectedTab"
}

/* ###################################################################################################################################### */
// MARK: Private Computed Properties
/* ###################################################################################################################################### */
extension NACCAppSceneDelegate {
    /* ################################################################## */
    /**
     Easy access to our navigation controller.
     */
    private var _navigationController: UINavigationController? {
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
    private var _initialViewController: NACCInitialViewController? {
        if let navigationController = _navigationController,
           let viewController = navigationController.viewControllers[0] as? NACCInitialViewController {
            return viewController
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: Internal Computed Class Properties
/* ###################################################################################################################################### */
extension NACCAppSceneDelegate {
    /* ################################################################## */
    /**
     Quick accessor for the app delegate, cast to this class. READ-ONLY.
     */
    class var appDelegateInstance: NACCAppSceneDelegate? { _appDelegateInstance }
}

/* ###################################################################################################################################### */
// MARK: Internal Computed Instance Properties
/* ###################################################################################################################################### */
extension NACCAppSceneDelegate {
    /* ################################################################## */
    /**
     This will contain the date for the selectors.
     */
    var date: Date? {
        get { _date }
        set { _date = newValue }
    }

    /* ################################################################## */
    /**
     This will contain the textual report, for the calculation.
     */
    var report: String {
        get { _report }
        set { _report = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: Internal Instance Methods
/* ###################################################################################################################################### */
extension NACCAppSceneDelegate {
    /* ################################################################## */
    /**
     This clears the original prefs, and prevents the reset on close.
     */
    func clearOriginalPrefs() {
        Self._originalPrefs = nil
    }
    
    /* ################################################################## */
    /**
     This will open and set up the app, in response to a URL.
     
     We parse the URL, and set a couple of instance variables, if the URL parameters are correct.
     
     The URL scheme is thus:
     
     nacc://_[YYYY-MM-DD[/N]]_
     
     The Universal Link Scheme is:
     
     https://nacc.littlegreenviper.com/_[YYYY-MM-DD[/N]]_
     
     _YYYY-MM-DD_ is a standard [ISO 8601 calendar date](https://en.wikipedia.org/wiki/ISO_8601#Calendar_dates) (For example, September first, 1980, is 1980-09-01).
     
     The earliest date is October 5, 1953 (1953-10-05)
     
     _N_ is the numerical index of a tab:
     
     - 0 is Keytag Array
     - 1 is Keytag Strip
     - 2 is Medallions
     
     - parameter inURL: The URL to be parsed.
     */
    func resolveURL(_ inURL: URL) {
        #if DEBUG
            print("\n#### Scene was opened from this URI: \(inURL)\n####\n")
        #endif
        if var dateString = inURL.query() {
            let splitter = dateString.split(separator: "/")
            if 1 < splitter.count,
               let tabInt = Int(splitter[1]),
               let tab = NACCTabBarController.TabIndexes(rawValue: tabInt) {
                dateString = String(splitter[0])
                _selectedTabFromURI = tab
            } else {
                _selectedTabFromURI = .undefined
            }
            
            #if DEBUG
                print("\tThe URL has this date: \(dateString), and wants this tab: \(_selectedTabFromURI?.rawValue ?? NACCTabBarController.TabIndexes.undefined.rawValue)")
            #endif
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateString) {
                open(to: Calendar.current.dateComponents([.year, .month, .day], from: date), with: _selectedTabFromURI ?? .undefined)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This opens the app, and sets it to the given cleandate.
     
     - parameter to: The cleadate, as date components.
     - parameter with: The tab index. Optional. Default is the initial screen.
     */
    func open(to inCleanDate: DateComponents, with inTabIndex: NACCTabBarController.TabIndexes = .undefined) {
        guard let minimumDate = Calendar.current.date(from: DateComponents(year: 1953, month: 10, day: 5)),
              let currentDate = Calendar.current.date(from: inCleanDate),
              (Calendar.current.startOfDay(for: minimumDate)..<Calendar.current.startOfDay(for: .now).addingTimeInterval(86400)).contains(currentDate)
        else { return }
        
        #if DEBUG
            print("Opening to date: \(currentDate), and tab: \(inTabIndex)")
        #endif

        _resetScreen = true
        NACCPersistentPrefs().cleanDate = currentDate
        NACCPersistentPrefs().lastSelectedTabIndex = inTabIndex.rawValue
        _initialViewController?.updateScreen()
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
        #if DEBUG
            print("\n#### Application Finished Launching.\n####\n")
        #endif
        Self._appDelegateInstance = self
        var cleanDate = NACCPersistentPrefs().cleanDate
        
        // This loads any previous prefs, and fetches the cleandate from them (then removes them).
        // We are changing the type of UserDefaults that we're storing, so we'll store them in our new format from now on.
        if let loadedPrefs = UserDefaults.standard.object(forKey: "NACCPersistentPrefs") as? [String: Any],
           let oldDate = loadedPrefs[NACCPersistentPrefs.Keys.cleanDate.rawValue] as? Date {
            cleanDate = oldDate
            UserDefaults.standard.removeObject(forKey: "NACCPersistentPrefs")
        }
        
        NACCPersistentPrefs().cleanDate = cleanDate
        
        return true
    }

    /* ################################################################## */
    /**
     Called when the scene connects. Returns the configuration to use for the scene.
     
     - parameter: The application instance (ignored).
     - parameter configurationForConnecting: The scene session that needs the configuration.
     - parameter options: The scene configuration options (also ignored)
     - returns: The scene configuration.
     */
    func application(_: UIApplication, configurationForConnecting inConnectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        #if DEBUG
            print("\n#### Application Delivering Configuration.\n####\n")
        #endif
        return UISceneConfiguration(name: Self._sceneConfigurationName, sessionRole: inConnectingSceneSession.role)
    }
    
    /* ################################################################## */
    /**
     Called when we receive a user activity.
     
     - parameter: The application instance (ignored).
     - parameter continue: The activity.
     - parameter restorationHandler: A completion handler (also ignored)
     - returns: True, if it was handled.
     */
    func application(_ application: UIApplication, continue inUserActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        guard inUserActivity.activityType == Self.displayCleantimeID,
              let parameters = inUserActivity.userInfo as? [String: String],
              let cleanDateString = parameters[Self.cleanDateUserDataID],
              let cleanDate = dateFormatter.date(from: cleanDateString)
        else { return false }
        
        #if DEBUG
            print("\n#### Application Received Display Cleantime Activity With: \(cleanDateString).\n####\n")
        #endif
        
        let tabIndex = NACCTabBarController.TabIndexes(rawValue: Int(parameters[Self.selectedTabUserDataID] ?? "-1") ?? -1) ?? .undefined

        self.open(to: Calendar.current.dateComponents([.year, .month, .day], from: cleanDate), with: tabIndex)
        
        return true
    }
}

/* ###################################################################################################################################### */
// MARK: UIWindowSceneDelegate Conformance
/* ###################################################################################################################################### */
extension NACCAppSceneDelegate: UIWindowSceneDelegate {
    /* ################################################################## */
    /**
     Called when the app is foregrounded via a URL.
     
     - parameter: The scene instance (ignored).
     - parameter openURLContexts: The Opening URL contexts (as a set).
     */
    func scene(_: UIScene, openURLContexts inURLContexts: Set<UIOpenURLContext>) {
        inURLContexts.forEach { self.resolveURL($0.url) }
    }
    
    /* ################################################################## */
    /**
     Called when the app is opened via a URL from a "cold start."
     - parameter: The scene instance.
     - parameter willConnectTo: The session being connected (ignored).
     - parameter options: This contains the options, among which, is the URL context.
     */
    func scene(_ inScene: UIScene, willConnectTo: UISceneSession, options inConnectionOptions: UIScene.ConnectionOptions) {
        if let url = inConnectionOptions.userActivities.first?.webpageURL ?? inConnectionOptions.urlContexts.first?.url {
            self.resolveURL(url)
        }
    }

    /* ################################################################## */
    /**
     Called when the app is opened via a URL (and launched).
     - parameter: The scene instance (ignored).
     - parameter continue: The activity being continued.
     */
    func scene(_: UIScene, continue inUserActivity: NSUserActivity) {
        if let url = inUserActivity.webpageURL {
            self.resolveURL(url)
        }
    }

    /* ################################################################## */
    /**
     Called when the app is about to come into the foreground.
     
     We use this to set the app to the initial screen, and also, to check if we have a URL specified.
     
     If we don't have a URL specified, then we restore to any saved state.
     
     - parameter: The scene instance (ignored).
     */
    func sceneWillEnterForeground(_: UIScene) {
        #if DEBUG
            print("\n#### Scene Entering Foreground.\n####\n")
        #endif
        if self._resetScreen {
            self._navigationController?.popToRootViewController(animated: false)
            self._initialViewController?.setDate(NACCPersistentPrefs().cleanDate, tabIndex: self._selectedTabFromURI)
        } else {
            self._initialViewController?.setDate()
        }
    }

    /* ################################################################## */
    /**
     Called when the app is about to come into the foreground.
     
     We use this to set the app to the initial screen, and also, to check if we have a URL specified.
     
     If we don't have a URL specified, then we restore to any saved state.
     
     - parameter: The scene instance (ignored).
     */
    func sceneDidBecomeActive(_: UIScene) {
        #if DEBUG
            print("\n#### Scene Becoming Active.\n####\n")
        #endif
        if self._resetScreen {
            self._navigationController?.popToRootViewController(animated: false)
            self._initialViewController?.setDate(NACCPersistentPrefs().cleanDate, tabIndex: self._selectedTabFromURI)
        }

        _resetScreen = false
    }
    
    /* ################################################################## */
    /**
     Called when the scene will be no longer visible.
     
     We use this to restore our prefs from any that were stored, when the app was called from a URL.
     
     - parameter: The scene instance (ignored).
     */
    func sceneDidEnterBackground(_: UIScene) {
        #if DEBUG
            print("\n#### Scene Entered Background.\n####\n")
        #endif
        
        self._navigationController?.viewControllers.forEach {
            // The first one, is in case we have a second modal over the main one (doesn't work for all of them).
            $0.presentedViewController?.presentedViewController?.dismiss(animated: false)
            $0.presentedViewController?.dismiss(animated: false)
        }
        
        if let originals = Self._originalPrefs {
            Self._originalPrefs = nil
            NACCPersistentPrefs().cleanDate = originals.cleanDate
            NACCPersistentPrefs().lastSelectedTabIndex = self._selectedTabFromURI?.rawValue ?? NACCTabBarController.TabIndexes.undefined.rawValue
        }
    }
}
