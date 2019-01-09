import UIKit

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
    var doneHandler = {}
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
        doneHandler()
    }
    
    @objc private func cancelDatePicker(){
        controller?.view.endEditing(true)
    }
}
