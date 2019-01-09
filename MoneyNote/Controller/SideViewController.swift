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
    var windowMode = false
    open var primary : UIViewController?
    private var position: Position = .right
    private var movement: Movement = .move
    private let screenSize = UIScreen.main.bounds.size
    private var window: SideWindow? = nil
    private var sideWidth = CGFloat(0)
    private var showed = false
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
    var windowColor: UIColor?{
        get{
            return window?.backgroundColor
        }
        set{
            window?.backgroundColor = newValue
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
        //toggle(to: false, sec: 0)
    }
    func create_windowMode(){
        if (window == nil){
            window = SideWindow(self)
            window!.windowLevel = UIWindow.Level(rawValue: keyWindow!.windowLevel.rawValue + 1)
            //window!.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
            window!.isHidden = false
            window!.rootViewController = self
        }
    }
    func elimimate(){
        if (windowMode){
            create_windowMode()
            return
        }
        self.view.removeFromSuperview()
        //toggle(to: false, sec: 0)
    }
    func elimimate_windowMode(){
        window = nil
        toggle(to: false, sec: 0){}
    }
    
//-------------------------------------------------------
    func initSideView(){
        if(windowMode){
            initSideView_windowMode()
            return
        }
        showed = false
        if(position == .left){
            self.view.frame = CGRect(x: -sw, y: y, width: sw, height: sh)
        }
        if(position == .right){
            self.view.frame = CGRect(x: w, y: y, width: sw, height: sh)
        }
    }
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
    func open(){
        toggle(to: true)
    }
    func close(){
        toggle(to: false)
    }
    func show(){
        toggle(to: true, sec: 0){}
    }
    func hide(){
        toggle(to: false, sec: 0){}
    }
    func toggle(){
        toggle(to: !showed)
    }
    func toggle(to: Bool){
        toggle(to: to, sec: 0.2){}
    }
    func toggle(to: Bool, sec: TimeInterval, complete: @escaping ()->()){
        if(sec==0){
            self.apply(to)
        }else{
            UIView.animate(withDuration: sec, animations: {
                self.apply(to)
            }){ _ in
                complete()
            }
        }
    }
    func apply(_ to: Bool){
        if(windowMode){
            apply_windowMode(to)
            return
        }
        let changed = (showed != to)
        showed = to
        let s = self.showed
        let sw = self.sw
        let w = self.w
        let h = self.h
        if(self.position == .left){
            self.view.frame.origin = CGPoint(x: s ? 0: -sw, y: y)
            if(self.movement == .shrink){
                if(changed){
                    let currentW = self.primary!.view.frame.size.width
                    self.primary!.view.frame = CGRect(x: s ? sw : 0, y: 0, width: currentW + (s ? -sw : sw), height: h)
                }
            }
            if(self.movement == .move){
                self.primary!.view.frame.origin = CGPoint(x: s ? sw : 0, y: 0)
            }
        }
        if(self.position == .right){
            self.view.frame.origin = CGPoint(x: s ? w - sw : w, y: y)
            if(self.movement == .shrink){
                if(changed){
                    let currentW = self.primary!.view.frame.size.width
                    self.primary!.view.frame = CGRect(x: 0, y: 0, width: currentW + (s ? -sw : sw), height: h)
                }
            }
            if(self.movement == .move){
                self.primary!.view.frame.origin = CGPoint(x: s ? -sw : 0, y: 0)
            }
        }
        self.primary!.view.layoutIfNeeded()
        self.view.layoutIfNeeded()
        self.animationHandler()
    }
    
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
}
//-----------------------------------------------
private class SideWindow: UIWindow {
    var sideController: SideViewController? = nil
    init(_ sideController: SideViewController) {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = nil
        self.sideController = sideController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        //var rect = sideController!.view.frame
        //rect.origin = CGPoint(x: 0, y: 0)
        //return rect.contains(point)
        let rect = sideController!.view.frame
        return rect.contains(point)
    }
}
