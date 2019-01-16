import UIKit

class SideViewController : UIViewController{
    enum Position{
        case left
        case right
    }
    enum Movement{
        case shrink
        case move
        case stay
    }
    var animationHandler = {}
    let windowMode = true
    var focusMode = true
    static private var animating = false
    private var focused: Bool{
        get{
            return !SideWindow.currentFocusVCStack.isEmpty && SideWindow.currentFocusVCStack.last == self
        }
    }
    open var primary : UIViewController?
    private var position: Position = .right
    private var movement: Movement = .move
    private let screenSize = UIScreen.main.bounds.size
    private var sideWidth = CGFloat(0)
    private var showed = false
    private var showed_prev = false
    private var topMargin = CGFloat(0)
    private var bottomMargin = CGFloat(0)
    private var keyWindow = UIApplication.shared.keyWindow
    private var sw: CGFloat{
        get{
            return self.sideWidth
        }
    }
    private var sh: CGFloat{
        get{
            return self.screenSize.height - self.topMargin - self.bottomMargin
        }
    }
    private var h: CGFloat{
        get{
            return self.screenSize.height
        }
    }
    private var w: CGFloat{
        get{
            return self.screenSize.width
            
        }
    }
    private var y: CGFloat{
        get{
            return self.topMargin
        }
    }
    var isOn: Bool{
        get{
            return showed
        }
    }
    private var window: SideWindow?{
        get{
            return SideWindow.shared
        }
    }
    var windowColor: UIColor?{
        get{
            return keyWindow?.backgroundColor
        }
        set{
            keyWindow?.backgroundColor = newValue
        }
    }
//-------------------------------------------------------
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    deinit{
        elimimate()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    func belongTo(_ primary: UIViewController){
        self.primary = primary
        create()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        if(view.subviews.count == 0){
            let v = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: UIScreen.main.bounds.height))
            v.backgroundColor = UIColor.black
            view.addSubview(v)
        }
        
        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = CGFloat(0)
        for subView in view.subviews{
            if(subView.frame.minX < minX){
                minX = subView.frame.minX
            }
            if(subView.frame.maxX > maxX){
                maxX = subView.frame.maxX
            }
            sideWidth = maxX - minX
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initSideView()
    }
//-------------------------------------------------------
    static func lockAnimating()->Bool{
        if(SideViewController.animating){return false}
        else{
            SideViewController.animating = true
        }
        return true
    }
    static func unlockAnimating(){
        SideViewController.animating = false
    }
    func setMargin(top: CGFloat, bottom: CGFloat){
        topMargin = top
        bottomMargin = bottom
    }
    func setRelation(position: Position, movement: Movement){
        self.position = position
        self.movement = movement
    }
    func create(){
        if (windowMode){
            create_windowMode()
            return
        }
        keyWindow?.addSubview(self.view)
    }
    func create_windowMode(){
        if (window == nil){
            SideWindow.create()
            window!.windowLevel = UIWindow.Level(rawValue: keyWindow!.windowLevel.rawValue + 2)
            //window!.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
            window!.isHidden = false
        }
        window?.addSubview(self.view)
        SideWindow.addSideViewController(self)
    }
    func elimimate(){
        toggle(to: false, sec: 0){}
        self.view.removeFromSuperview()
        if (windowMode){
            if(window?.subviews.count==0){
                SideWindow.elimimate()
            }
        }
    }
    
//-------------------------------------------------------
    func initSideView(){
        showed = false
        if(position == .left){
            self.view.frame = CGRect(x: -sw, y: y, width: sw, height: sh)
        }
        if(position == .right){
            self.view.frame = CGRect(x: w, y: y, width: sw, height: sh)
        }
        
    }
    /*
    func initSideView_windowMode(){
        showed = false
        if(position == .left){
            window?.frame =  CGRect(x: -sw, y: 0, width: sw, height: h)
            self.view.frame = CGRect(x: 0, y: y, width: sw, height: sh)
            //self.view.frame = CGRect(x: -sw, y: y, width: sw, height: sh)
        }
        if(position == .right){
            window?.frame =  CGRect(x: w, y: 0, width: sw, height: h)
            self.view.frame = CGRect(x: 0, y: y, width: sw, height: sh)
            //self.view.frame = CGRect(x: w, y: y, width: sw, height: sh)
        }
    }
    */
    
    func open(){
        toggle(to: true)
    }
    func close(){
        toggle(to: false)
    }
    func show(){
        view.isHidden = false
        toggle(to: true, sec: 0){}
    }
    func hide(){
        view.isHidden = true
        toggle(to: false, sec: 0){}
    }
    func toggle(){
        toggle(to: !showed)
    }
    
    func toggle(to show: Bool){
        view.isHidden = false
        toggle(to: show, sec: 0.2){}
    }
    
    func toggle(to show: Bool, sec: TimeInterval, complete: @escaping ()->()){
        if(show && focusMode && !focused){SideWindow.pushFocus(self)}
        if(sec==0){
            self.showed = show
            self.apply()
            if(!show && focused){SideWindow.popFocus()}
        }else{
            if(!SideViewController.lockAnimating()){return}
            UIView.animate(withDuration: sec, animations: {
                self.showed = show
                self.apply()
            }){ _ in
                if(!show && self.focused){SideWindow.popFocus()}
                SideViewController.unlockAnimating()
                complete()
            }
        }
    }
    
    func apply(){
        if(showed_prev == showed){return }
        showed_prev = showed
        let s = showed
        let sw = self.sw
        let w = self.w
        let h = self.h
        if(self.position == .left){
            self.view.frame.origin = CGPoint(x: s ? 0: -sw, y: y)
            if(self.movement == .shrink){
                let currentW = self.primary!.view.frame.size.width
                self.primary!.view.frame = CGRect(x: s ? sw : 0, y: 0, width: currentW + (s ? -sw : sw), height: h)
            }
            if(self.movement == .move){
                self.primary!.view.frame.origin = CGPoint(x: s ? sw : 0, y: 0)
            }
        }
        if(self.position == .right){
            self.view.frame.origin = CGPoint(x: s ? w - sw : w, y: y)
            if(self.movement == .shrink){
                let currentW = self.primary!.view.frame.size.width
                self.primary!.view.frame = CGRect(x: 0, y: 0, width: currentW + (s ? -sw : sw), height: h)
            }
            if(self.movement == .move){
                self.primary!.view.frame.origin = CGPoint(x: s ? -sw : 0, y: 0)
            }
        }
        if(s && focused){
            SideWindow.blur(true)
        }else{
            SideWindow.blur(false)
        }
        
        self.primary!.view.layoutIfNeeded()
        self.view.layoutIfNeeded()
        self.animationHandler()
    }
    /*
    func apply_windowMode(_ to: Bool){
        let changed = (showed != to)
        showed = to
        let s = self.showed
        let sw = self.sw
        let w = self.w
        let h = self.h
        if(self.position == .left){
            self.window?.frame.origin = CGPoint(x: s ? 0: -sw, y: 0)
            //self.view.frame.origin = CGPoint(x: s ? 0: -sw, y: y)
            if(self.movement == .shrink){
                if(changed){
                    let currentW = self.keyWindow!.frame.size.width
                    self.keyWindow?.frame = CGRect(x: s ? sw : 0, y: 0, width: currentW + (s ? -sw : sw), height: h)
                }
            }
            if(self.movement == .move){
                self.keyWindow?.frame.origin = CGPoint(x: s ? sw : 0, y: 0)
            }
        }
        if(self.position == .right){
            self.window?.frame.origin = CGPoint(x: s ? w - sw : w, y: 0)
            //self.view.frame.origin = CGPoint(x: s ? w - sw : w, y: y)
            if(self.movement == .shrink){
                if(changed){
                    let currentW = self.keyWindow!.frame.size.width
                    self.keyWindow?.frame = CGRect(x: 0, y: 0, width: currentW + (s ? -sw : sw), height: h)
                }
            }
            if(self.movement == .move){
                self.keyWindow?.frame.origin = CGPoint(x: s ? -sw : 0, y: 0)
            }
        }
        self.keyWindow?.layoutIfNeeded()
        self.window?.layoutIfNeeded()
        self.animationHandler()
     }
 */
}
//-----------------------------------------------
class SideWindow: UIWindow {
    private static var _shared: SideWindow? = nil
    static var sideViewControllers: [SideViewController] = []
    static var blurBack: UIView? = nil
    static var currentFocusVCStack: [SideViewController] = []
    static var shared: SideWindow?{
        get{
            return _shared
        }
    }
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = nil
        SideWindow.blurBack = UIView(frame: frame)
        addSubview(SideWindow.blurBack!)
        SideWindow.blurBack?.backgroundColor = UIColor.black
        SideWindow.blurBack?.alpha = 0
        windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude - 1)
    }
    static func addSideViewController(_ svc: SideViewController){
        sideViewControllers.append(svc)
    }
    static func removeSideViewController(_ svc: SideViewController){
        sideViewControllers = sideViewControllers.filter{$0 != svc}
    }
    static func create(){
        if(_shared == nil){
            _shared = SideWindow()
        }
    }
    static func elimimate(){
        _shared = nil
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func blur(_ state: Bool){
        if(state){
            blurBack?.alpha = 0.5
        }else{
            blurBack?.alpha = 0
        }
    }
    
    static func pushFocus(_ svc: SideViewController){
        currentFocusVCStack.append(svc)
        shared?.bringSubviewToFront(blurBack!)
        shared?.bringSubviewToFront(svc.view)
    }
    static func popFocus(){
        currentFocusVCStack.removeLast()
        if(!currentFocusVCStack.isEmpty){
            shared?.bringSubviewToFront(blurBack!)
            shared?.bringSubviewToFront(currentFocusVCStack.last!.view)
        }
    }
    static func releaseFocus(){
        currentFocusVCStack = []
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if(SideWindow.currentFocusVCStack.isEmpty){
            for view in self.subviews{
                if view == SideWindow.blurBack {continue}
                let rect = view.frame
                if(rect.contains(point)){
                    return true
                }
            }
            return false
        }else{
            let svc = SideWindow.currentFocusVCStack.last!
            let rect = svc.view.frame
            if(!rect.contains(point)){
                svc.close()
            }
            return true
        }
    }
}
