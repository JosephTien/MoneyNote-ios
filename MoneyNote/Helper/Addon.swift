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

extension UITableViewCell{
    func setCellStyle(){
        let f = frame
        let container = UIView(frame: CGRect(x: f.minX+10, y: f.minY, width: f.width-20, height: f.height))
        container.layer.cornerRadius = 5
        container.layer.borderWidth = 1
        container.setFloating()
        contentView.addSubview(container)
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

extension UIView{
    func setFloating(){
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowOpacity = 0.2
        self.layer.borderWidth = 1
    }
    func alignCenter(to: UIView){
        //imgQRCode.translatesAutoresizingMaskIntoConstraints = false //?
        to.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: to, attribute: .centerX, multiplier: 1, constant: 0))
        to.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: to, attribute: .centerY, multiplier: 1, constant: 0))
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


class PickerView : UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource{
    var list: [String] = []
    var selected: String = ""
    var syncTarget: UIPickerView? = nil
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 14)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = list[row]
        pickerLabel?.textColor = UIColor.blue
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected = list[row]
        syncTarget?.selectRow(row, inComponent: component, animated: true)
    }
}


class ListPickerServic{
    var controller: UIViewController?
    var view: UIView?
    var sync: UIPickerView?
    let listPicker = PickerView()
    let toolbar = UIToolbar()
    init(_ controller: UIViewController, _ view: UIView){//UITextField
        self.controller = controller
        self.view = view
    }
    
    func setList(_ list: [String]){
        listPicker.list = list
        listPicker.dataSource = listPicker
        listPicker.delegate = listPicker
        listPicker.selected = list[0]
        //refresh()
    }
    func setSync(_ pickerView :UIPickerView){
        pickerView.dataSource = listPicker
        pickerView.delegate = listPicker
        listPicker.syncTarget = pickerView
    }
    
    func setListPicker() -> ListPickerServic{
        //let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneListPicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelListPicker));
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        if let textfield = view as? UITextField{
            textfield.inputAccessoryView = toolbar
            textfield.inputView = listPicker
        }else{
            let gesture = UITapGestureRecognizer(target: self, action: #selector(showListPicker))
            view?.addGestureRecognizer(gesture)
        }
        return self
    }
    
    @objc func showListPicker(){
        let textfield = UITextField()
        controller?.view.addSubview(textfield)
        textfield.inputAccessoryView = toolbar
        textfield.inputView = listPicker
        textfield.becomeFirstResponder()
    }
    
    func refresh(){
        listPicker.reloadAllComponents()
    }
    
    @objc private func doneListPicker(){
        if let textfield = view as? UITextField{
            textfield.text=listPicker.selected
        }
        controller?.view.endEditing(true)
    }
    
    @objc private func cancelListPicker(){
        controller?.view.endEditing(true)
    }
    
    /*
     //usage example
     listPickerService = ListPickerServic(self, btn_sheet).setListPicker()
     listPickerService?.setList(["Local","Cloud"])
     listPickerService?.setSync(field_sheet)
     */
}

class DatePickerServic{
    var controller:UIViewController?
    var textfield:UITextField?
    let datePicker = UIDatePicker()
    init(_ controller:UIViewController,_ textfield:UITextField){
        self.controller = controller
        self.textfield = textfield
    }
    func showDatePicker() -> DatePickerServic{
        //Formate Date
        datePicker.datePickerMode = .date
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        textfield?.inputAccessoryView = toolbar
        textfield?.inputView = datePicker
        return self
    }
    
    @objc private func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        textfield?.text=formatter.string(from: datePicker.date)
        controller?.view.endEditing(true)
    }
    
    @objc private func cancelDatePicker(){
        controller?.view.endEditing(true)
    }
}

class DialogService {
    var controller: UIViewController?
    init(_ controller: UIViewController){
        self.controller = controller
    }
    static var commonBeforeHandler = {}
    static var commonFinalHandler = {}
    func showDialog_comfirm(_ title: String?,_ msg: String?, function: @escaping ()->()) {
        DialogService.commonBeforeHandler()
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler:
            {(action: UIAlertAction!) in
                DialogService.commonFinalHandler()
            }
        )
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "確定", style: .destructive, handler: {
            (action: UIAlertAction!) in
                DialogService.commonFinalHandler()
                function()
            }
        )
        alertController.addAction(okAction)
        controller?.present(alertController, animated: true, completion: nil)
    }
    
    func showDialog_failed(_ title: String?,_ msg: String?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        DialogService.commonBeforeHandler()
        let okAction = UIAlertAction(title: "確定", style: .default, handler:
            {(action: UIAlertAction!) in
                DialogService.commonFinalHandler()
            }
        )
        alertController.addAction(okAction)
        controller?.present(alertController, animated: true, completion: nil)
    }

    func showDialog_ok(_ title: String?,_ msg: String?, function: @escaping ()->()) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        DialogService.commonBeforeHandler()
        let okAction = UIAlertAction(title: "確定", style: .default, handler: {
            (action: UIAlertAction!) in
            DialogService.commonFinalHandler()
            function()
        })
        alertController.addAction(okAction)
        controller?.present(alertController, animated: true, completion: nil)
    }
    
    func showDialog_done(_ title: String?,_ msg: String?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        DialogService.commonBeforeHandler()
        self.controller?.present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.controller?.presentedViewController?.dismiss(animated: false, completion: nil)
            DialogService.commonFinalHandler()
        }
    }
    func showDialog_done(_ title: String?,_ msg: String?, action: @escaping ()->()) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        DialogService.commonBeforeHandler()
        self.controller?.present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.controller?.presentedViewController?.dismiss(animated: false, completion: action)
            DialogService.commonFinalHandler()
        }
    }

    func showDialog_ask(_ title: String?,_ msg: String?, function: @escaping ()->()) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        DialogService.commonBeforeHandler()
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler:
            {(action: UIAlertAction!) in
                DialogService.commonFinalHandler()
            }
        )
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: {
            (action: UIAlertAction!) in
            DialogService.commonFinalHandler()
            function()
        })
        alertController.addAction(okAction)
        controller?.present(alertController, animated: true, completion: nil)
    }
}
