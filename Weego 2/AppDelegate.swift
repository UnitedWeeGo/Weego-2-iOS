import UIKit
import Firebase
import FirebaseDatabase
import NotificationCenter
import UserNotifications
import Fabric
import Crashlytics
import FBSDKCoreKit
import FBSDKLoginKit
import AsyncDisplayKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  var window: UIWindow?
  private var mainStore: Storage?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    Fabric.with([Crashlytics.self])

    FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "unitedwego.Weego-2"
    FirebaseApp.configure()

    mainStore = Storage()

    // Testing simulation of crash
    let when = DispatchTime.now() + 5 // change 2 to desired number of seconds
    DispatchQueue.main.asyncAfter(deadline: when) {
      //            Crashlytics.sharedInstance().crash()
      //            Crashlytics.sharedInstance().throwException()
    }

    // Facebook
    FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

    let rootViewController = MainController(withStorage: mainStore!)
    let navigationController = ASNavigationController(rootViewController: rootViewController)
    navigationController.isNavigationBarHidden = true

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = navigationController
    window?.backgroundColor = UIColor.white
    window?.makeKeyAndVisible()
    window?.makeKeyAndVisible()

    // Monitors login/out for cloud func logging of info
    _ = Auth.auth().addStateDidChangeListener { (auth, user) in
        if let user = user {
            
            print("User photo URL: \(user.providerData[0].photoURL?.absoluteString ?? "")")
            
            let userRef = Database.database().reference().child("queues/login").child(user.uid)
            userRef.removeValue(completionBlock: { (error, ref) in
                
                let loginRecord = [
                    "displayName": user.providerData[0].displayName ?? "",
                    "photoURL": user.providerData[0].photoURL?.absoluteString ?? "",
                    "fbUID": user.providerData[0].uid
                ] as [String : Any]
                
                ref.setValue(loginRecord)
            })
        } else {
            // No User is signed in.
        }
    }
    
    return true
  }

  func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

    UNUserNotificationCenter.current().delegate = self

    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization (
      options: authOptions,
      completionHandler: {_, _ in })

    application.registerForRemoteNotifications()

    return true
  }


  // Dynamic Link Handlers -----------------------------------------
  // https://e398h.app.goo.gl/
  // unitedwego.Weego-2
  // https://e398h.app.goo.gl/apple-app-site-association
  // {"applinks":{"apps":[],"details":[{"appID":"PQEPQNBEWP.unitedwego.Weego-2","paths":["/*"]}]}}


  func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
    -> Bool {
      return self.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "")
  }

  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

    print("Handling a link with the open url method")

    let dynamicLink = DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)

    if let dnl = dynamicLink, let _ = dnl.url {
      self.handleDynamicLink(dynamiclink: dnl)
      return true
    }

    let handled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    return handled
  }

  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    guard let dynamicLinks = DynamicLinks.dynamicLinks() else {
      return false
    }
    let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { [weak self] (dynamiclink, error) in
      guard let dnl = dynamiclink, let _ = dnl.url else {
        print("dynamicLinks error, url: \(String(describing: dynamiclink?.url))")
        return
      }
      self?.handleDynamicLink(dynamiclink: dnl)
    }
    return handled
  }

  func handleDynamicLink(dynamiclink: DynamicLink) {
    print("handleDynamicLink url: \(String(describing: dynamiclink.url))")
  }

  // End Dynamic Link Handlers -----------------------------------------

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

}

