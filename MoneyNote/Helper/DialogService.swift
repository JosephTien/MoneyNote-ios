import UIKit

private class DialogServiceWindow: UIWindow{
    private let vc = UIViewController()
    init() {
        super.init(frame: UIScreen.main.bounds)
        self.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        self.backgroundColor = nil
        self.isHidden = false
        self.rootViewController = vc
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
    func getVC()-> UIViewController{
        return vc
    }
}

class DialogService {
    static private var window: DialogServiceWindow? = nil
    static private var vc: UIViewController?{
        get{
            return window?.getVC()
        }
    }
    private static func commonBeforeHandler() {
        if(window == nil){
            window = DialogServiceWindow()
        }
    }
    private static func commonFinalHandler() {
        window?.isHidden = true
        vc?.view.isHidden = true
        window = nil //unregist
    }
    
    static func showDialog_comfirm(_ title: String?,_ msg: String?, function: @escaping ()->()) {
        commonBeforeHandler()
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler:
            {(action: UIAlertAction!) in
                commonFinalHandler()
            }
        )
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "確定", style: .destructive, handler: {
            (action: UIAlertAction!) in
            commonFinalHandler()
            function()
        }
        )
        alertController.addAction(okAction)
        vc?.present(alertController, animated: true, completion: nil)
    }
    
    static func showDialog_ask(_ title: String?,_ msg: String?, function: @escaping ()->()) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        commonBeforeHandler()
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler:
        {(action: UIAlertAction!) in
            commonFinalHandler()
        }
        )
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: {
            (action: UIAlertAction!) in
            commonFinalHandler()
            function()
        })
        alertController.addAction(okAction)
        vc?.present(alertController, animated: true, completion: nil)
    }
    
    static func showDialog_failed(_ title: String?,_ msg: String?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        commonBeforeHandler()
        let okAction = UIAlertAction(title: "確定", style: .default, handler:
            {(action: UIAlertAction!) in
                commonFinalHandler()
            }
        )
        alertController.addAction(okAction)
        vc?.present(alertController, animated: true, completion: nil)
    }
    
    static func showDialog_ok(_ title: String?,_ msg: String?, function: @escaping ()->()) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        commonBeforeHandler()
        let okAction = UIAlertAction(title: "確定", style: .default, handler: {
            (action: UIAlertAction!) in
            commonFinalHandler()
            function()
        })
        alertController.addAction(okAction)
        vc?.present(alertController, animated: true, completion: nil)
    }
    
    static func showDialog_done(_ title: String?,_ msg: String?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        commonBeforeHandler()
        self.vc?.present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.vc?.presentedViewController?.dismiss(animated: false, completion: nil)
            commonFinalHandler()
        }
    }
    static func showDialog_done(_ title: String?,_ msg: String?, action: @escaping ()->()) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        commonBeforeHandler()
        self.vc?.present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.vc?.presentedViewController?.dismiss(animated: false, completion: action)
            commonFinalHandler()
        }
    }
    static func showDialog_input(_ title: String?,_ msg: String?, function: @escaping (String)->()) {
        commonBeforeHandler()
        let alertController = UIAlertController(
            title: title,
            message: msg,
            preferredStyle: .alert)
        
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = ""
        }
        let tf = ((alertController.textFields?.first)! as UITextField)
        alertController.addAction(
            UIAlertAction(
                title: "取消",
                style: .cancel,
                handler: {_ in
                    commonFinalHandler()
                }
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: "確定",
                style: UIAlertAction.Style.default){ action in
                let string = tf.text!
                if(string == ""){
                    showDialog_failed("不允許為空", nil)
                }else{
                    function(string)
                    commonFinalHandler()
                }
            }
        )
        vc?.present(
            alertController,
            animated: true,
            completion: nil
        )
    }
}
