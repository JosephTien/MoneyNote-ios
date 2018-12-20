import UIKit

class FloatButton: UIButton{
    enum Position{
        case BottomLeft
        case BottomRight
        case BottomCenter
        case UpLeft
        case UpRight
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowOpacity = 0.2
        self.layer.borderWidth = 1
    }
    static let buttonDiameter: CGFloat = 44
    static let fix: CGFloat = 10.0
    static var navBarHight: CGFloat = 0
    static func setNavHeight(controller: UIViewController){
        if let navController = controller.navigationController{
            navBarHight = navController.isToolbarHidden ? 0 : navController.navigationBar.frame.height
        }
    }
    static func getFrame(_ controller: UIViewController, _ position: Position)->CGRect{
        return getFrame(base: controller, position: position, hasStatus: false, hasNav: false);
    }
    static func getFrame(base controller: UIViewController, position: Position, hasStatus: Bool, hasNav: Bool)->CGRect{
        let lift = (hasStatus ? FloatButton.navBarHight : 0) +
            (hasStatus ?UIApplication.shared.statusBarFrame.height : 0)
        let view = controller.view!
        let h = view.bounds.height
        let w = view.bounds.width
        let w_d = w - buttonDiameter
        let h_d = h - buttonDiameter - lift
        if position == .BottomRight{
            return CGRect(x: w_d-fix, y: h_d-fix, width: buttonDiameter, height: buttonDiameter)
        }
        else if position == .BottomLeft {
            return CGRect(x: fix, y: h_d-fix, width: buttonDiameter, height: buttonDiameter)
        }
        else if position == .BottomCenter {
            return CGRect(x: w/2-buttonDiameter/2, y: h_d-fix, width: buttonDiameter, height: buttonDiameter)
        }
        return CGRect()
    }
    var function: (()->())?
    func set(_ view: UIView, text: String, function: @escaping (()->()))->FloatButton{
        view.addSubview(self)
        return set(text: text, function: function)
    }
    func set(text: String, function: @escaping (()->()))->FloatButton{
        self.isEnabled = !(text=="")
        self.isHidden = !self.isEnabled
        setTitle(text, for: .normal)//ex: "✔", "✖"
        setTitleColor(UIColor.black, for: .normal)
        self.function = function
        layer.cornerRadius = FloatButton.buttonDiameter/2
        return self
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.function!()
    }
}

private class FloatingWindow: UIWindow {
    var buttons: [UIButton?] = []
    var floatingController: FloatingController?
    var blockAnyTouch = false
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if(blockAnyTouch){return true}
        var trigger: Bool = false
        for button in buttons{
            guard let button = button else {continue}
            if (button.isHidden){continue}
            let buttonPoint = convert(point, to: button)
            trigger = trigger || button.point(inside: buttonPoint, with: event)
        }
        return trigger
    }
}

class FloatingController: UIViewController {
    private let window = FloatingWindow()
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    static var sharedInstance: FloatingController? = nil
    var msgLabel = UILabel()
    init() {
        super.init(nibName: nil, bundle: nil)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = false
        window.rootViewController = self
        FloatingController.sharedInstance = self
        self.view.addSubview(msgLabel)
    }
    func addButtonPoint(button: UIButton){
        window.buttons.append(button)
    }
    static func hideButtons(_ hide: Bool){
        for button in FloatingController.sharedInstance!.window.buttons{
            if ((button?.isEnabled)!){
                button?.isHidden = hide
            }else{
                button?.isHidden = true
            }
        }
    }
    static func hide(){
        FloatingController.sharedInstance!.view.isHidden = true
        FloatingController.hideButtons(true)
    }
    static func show(){
        FloatingController.sharedInstance!.view.isHidden = false
        FloatingController.hideButtons(false)
    }
    static func coverAndShow(_ string: String){
        FloatingController.show()
        FloatingController.hideButtons(true)
        FloatingController.sharedInstance!.view.backgroundColor = UIColor.white
        FloatingController.sharedInstance!.window.blockAnyTouch = true
        let shared = FloatingController.sharedInstance!
        shared.msgLabel.text = string
        shared.msgLabel.textAlignment = .center
        shared.msgLabel.isHidden = false
        shared.msgLabel.frame = shared.view.frame
    }
    static func cover(_ enable: Bool){
        FloatingController.show()
        if(enable){
            FloatingController.hideButtons(true)
            FloatingController.sharedInstance!.view.backgroundColor = UIColor.white
            FloatingController.sharedInstance!.window.blockAnyTouch = true
        }else{
            FloatingController.hideButtons(false)
            FloatingController.sharedInstance!.view.backgroundColor = nil
            FloatingController.sharedInstance!.window.blockAnyTouch = false
            FloatingController.sharedInstance!.msgLabel.isHidden = true
        }
    }
    /*
    private(set) var button: UIButton!
    override func loadView() {
        let view = UIView()
        let button = UIButton(type: .custom)
        button.setTitle("Floating", for: .normal)
        button.setTitleColor(UIColor.green, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize.zero
        button.sizeToFit()
        button.frame = CGRect(origin: CGPoint(x: 10, y: 10), size: button.bounds.size)
        button.autoresizingMask = []
        view.addSubview(button)
        self.view = view
        self.button = button
        window.button = button
        
        let panner = UIPanGestureRecognizer(target: self, action: #selector(panDidFire))
        button.addGestureRecognizer(panner)
    }
    
    @objc func panDidFire(panner: UIPanGestureRecognizer) {
        let offset = panner.translation(in: view)
        panner.setTranslation(CGPoint.zero, in: view)
        var center = button.center
        center.x += offset.x
        center.y += offset.y
        button.center = center
        
        if panner.state == .ended || panner.state == .cancelled {
            UIView.animate(withDuration: 0.3) {
                self.snapButtonToSocket()
            }
        }
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        snapButtonToSocket()
    }
    
    private var sockets: [CGPoint] {
        let buttonSize = button.bounds.size
        let rect = view.bounds.insetBy(dx: 4 + buttonSize.width / 2, dy: 4 + buttonSize.height / 2)
        let sockets: [CGPoint] = [
            CGPoint(x: rect.minX, y: rect.minY),
            CGPoint(x: rect.minX, y: rect.maxY),
            CGPoint(x: rect.maxX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.maxY),
            CGPoint(x: rect.midX, y: rect.midY)
        ]
        return sockets
    }
    
    private func snapButtonToSocket() {
        var bestSocket = CGPoint.zero
        var distanceToBestSocket = CGFloat.infinity
        let center = button.center
        for socket in sockets {
            let distance = hypot(center.x - socket.x, center.y - socket.y)
            if distance < distanceToBestSocket {
                distanceToBestSocket = distance
                bestSocket = socket
            }
        }
        button.center = bestSocket
    }
    */
}
