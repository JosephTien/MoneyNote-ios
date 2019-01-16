import UIKit

extension Date{
    func secondFrom1970()->Int{
        return Int(Date().timeIntervalSince1970)
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UITextField{
    func setEnable(_ state: Bool){
        isEnabled = state
        if !state{
            borderStyle = .none
            //textAlignment = .center
        }else{
            borderStyle = .roundedRect
            //textAlignment = .right
        }
    }
}

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

extension UITableViewCell{
    func setCellStyle()->UIView{
        let f = frame
        //let container = UIView(frame: CGRect(x: f.minX+10, y: f.minY, width: f.width-20, height: f.height))
        let container = UIView()
        container.layer.cornerRadius = 5
        container.layer.borderWidth = 1
        container.setFloating()
        contentView.addSubview(container)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        let heightConstrain = NSLayoutConstraint(item: container, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute , multiplier: 1, constant: f.height)
        let leftConstrain = NSLayoutConstraint(item: container, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10)
        let rightConstrain = NSLayoutConstraint(item: container, attribute: .trailing , relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10)
        contentView.addConstraint(heightConstrain)
        contentView.addConstraint(leftConstrain)
        contentView.addConstraint(rightConstrain)
        return container
    }
    
    func setDeleteLine()->UIView{
        let deleteLine = UIView()
        deleteLine.layer.borderWidth = 1
        deleteLine.setFloating()
        contentView.addSubview(deleteLine)
        
        deleteLine.translatesAutoresizingMaskIntoConstraints = false
        let heightConstrain = NSLayoutConstraint(item: deleteLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute , multiplier: 1, constant: 2)
        let leftConstrain = NSLayoutConstraint(item: deleteLine, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10)
        let rightConstrain = NSLayoutConstraint(item: deleteLine, attribute: .trailing , relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10)
        let centerYConstrain = NSLayoutConstraint(item: deleteLine, attribute: .centerY , relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        contentView.addConstraint(heightConstrain)
        contentView.addConstraint(leftConstrain)
        contentView.addConstraint(rightConstrain)
        contentView.addConstraint(centerYConstrain)
        return deleteLine
    }
    
}

extension UICollectionViewCell{
    func setCellStyle(){
        layer.cornerRadius = 5
        layer.borderWidth = 1
        setFloating()
    }
}

extension UIButton{
    func setBorder(color: UIColor)->UIButton{
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
        return self
    }
    func setBorder()->UIButton{
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        return self
    }
    func setRoundStyle()->UIButton{
        layer.cornerRadius = frame.height/2
        return self
    }
    func setBlackText()->UIButton{
        setTitleColor(UIColor.black, for: .normal)
        return self
    }
}

typealias UIControlTargetClosure = () -> ()
 
class ClosureWrapper: NSObject {
    let closure: UIControlTargetClosure
    init(_ closure: @escaping UIControlTargetClosure) {
        self.closure = closure
    }
}

extension UIControl {
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
 
    private var targetClosure: UIControlTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
     }
 
    func addAction(for event: UIControl.Event, _ closure: @escaping UIControlTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIButton.closureAction), for: event)
     }
    
    func setAction(for event: UIControl.Event, _ closure: @escaping UIControlTargetClosure) {
        removeActions()
        addAction(for: event, closure)
    }
    
    func removeActions() {
        objc_removeAssociatedObjects(self)
    }
 
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure()
     }
 }


extension UIView{
    func setFloating(){
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowOpacity = 0.2
        self.layer.borderWidth = 1
    }
    func alignCenter(to: UIView){
        translatesAutoresizingMaskIntoConstraints = false
        to.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: to, attribute: .centerX, multiplier: 1, constant: 0))
        to.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: to, attribute: .centerY, multiplier: 1, constant: 0))
    }
    func fullWidth(to: UIView){
        translatesAutoresizingMaskIntoConstraints = false
        to.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: to, attribute: .leading, multiplier: 1, constant: 0))
        to.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing , relatedBy: .equal, toItem: to, attribute: .trailing, multiplier: 1, constant: 0))
    }
    func fullWidth(to: UIView, space: CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        to.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: to, attribute: .leading, multiplier: 1, constant: space))
        to.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing , relatedBy: .equal, toItem: to, attribute: .trailing, multiplier: 1, constant: -space))
    }
    func setHeightConstrain(to: UIView, height: CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        to.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute , multiplier: 1, constant: height))
    }
}


extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}



