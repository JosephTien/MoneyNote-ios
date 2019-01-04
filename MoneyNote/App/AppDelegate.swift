import Google
import GoogleSignIn
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static var currentSheetIdx: Int? = nil
    static var currentItemIdx: Int? = nil
    static var floatingController: FloatingController?
    static var floatingButtons: [FloatButton?] = [nil,nil,nil,nil]
    static let toolBarHeight = FloatButton.buttonDiameter+FloatButton.fix * 2
    static let statusBarHeight = CGFloat(20)
//---------------------------------------------
    func start(){
        DM.loadTable()
        DM.loadUsualList()
        //Initial The Floating Button
        AppDelegate.floatingController = FloatingController()
        let controller = AppDelegate.floatingController!
        AppDelegate.floatingButtons[0] =
            FloatButton.init(frame: FloatButton.getFrame(controller, .BottomLeft))
                .set(controller.view, text: ""){}
        AppDelegate.floatingButtons[1] =
            FloatButton.init(frame: FloatButton.getFrame(controller, .BottomCenter))
                .set(controller.view, text: ""){}
        AppDelegate.floatingButtons[2] =
            FloatButton.init(frame: FloatButton.getFrame(controller, .BottomRight))
                .set(controller.view, text: ""){}
        AppDelegate.floatingButtons[3] =
            FloatButton.init(frame: FloatButton.getFrame(controller, .full))
                .set(controller.view, text: ""){}
        //Modify the default style of full button
        AppDelegate.floatingButtons[3]?.layer.borderWidth = 0
        //Initial the point area of floating button
        for i in (0..<4){
            AppDelegate.floatingController?.addButtonPoint(button: AppDelegate.floatingButtons[i]!)
        }
        //Intial the action of Floating Button when Dialoag show
        DialogService.commonBeforeHandler = FloatingController.hide
        DialogService.commonFinalHandler = FloatingController.show
    }
    /*
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
     */
    //------------- Google Service -------------
    func applicationDidFinishLaunching(_ application: UIApplication) {
        start()
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
    }
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplication.OpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
}

