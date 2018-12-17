//
//  ViewController.swift
//  AccountSheet
//
//  Created by 田茂堯 on 2018/11/27.
//  Copyright © 2018 JTien. All rights reserved.
//

import UIKit

class NewItemViewController: UITableViewController, UITextFieldDelegate, MyUiProtocol, MyDataProtocol {
    
    @IBOutlet weak var field_io: UISegmentedControl!
    @IBOutlet weak var field_date: UITextField!
    @IBOutlet weak var field_name: UITextField!
    @IBOutlet weak var field_sort: UITextField!
    @IBOutlet weak var field_state: UISwitch!
    @IBOutlet weak var field_payer: UITextField!
    @IBOutlet weak var field_receipt: UISwitch!
    @IBOutlet weak var field_amount: UITextField!
    @IBOutlet weak var label_state: UILabel!
    @IBOutlet weak var btn_photo: UIButton!
    @IBOutlet weak var tablecell_payer: UIView!
    @IBOutlet weak var tablecell_receipt: UITableViewCell!
    @IBOutlet weak var tablecell_photo: UIView!
    @IBOutlet weak var image_photo: UIImageView!
    //*************** My Variable ***************//
    var datePickerService: DatePickerServic?
    var editMode = true
    //*************** MyUi ***************//
    
    func uiInit(){
        //Press retuen to close keyboard
        self.hideKeyboardWhenTappedAround()
        self.field_name.delegate = self
        self.field_payer.delegate = self
        self.field_amount.delegate = self
        
        //hide payer view_payer and picture
        switchChanged()
        field_io.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        field_state.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        field_receipt.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
        //photo button
        btn_photo.layer.borderWidth = 1
        btn_photo.layer.borderColor = UIColor.gray.cgColor
        
        //date picker dialog
        datePickerService = DatePickerServic(self, field_date).showDatePicker()
        
        //Photo Picker
        btn_photo.addTarget(self, action: #selector(loadPhoto), for: UIControl.Event.primaryActionTriggered)
        
    }
    func setFloatingButton(){
        _ = AppDelegate.floatingButtons[0]!.set(text: "✖"){
            self.navigationController?.popViewController(animated: false)
        }
        _ = AppDelegate.floatingButtons[1]!.set(text: ""){}
        _ = AppDelegate.floatingButtons[2]!.set(text: "✔"){
            self.addNewItem()
        }
    }
    
    func uiChange(){
        //tablecell_payer.isHidden = field_io.selectedSegmentIndex == 1
        tablecell_receipt.isHidden = field_io.selectedSegmentIndex == 1
        tablecell_photo.isHidden = field_io.selectedSegmentIndex == 1 || !field_receipt.isOn
        if(!field_receipt.isOn){
            image_photo.image = nil
        }
        if(field_io.selectedSegmentIndex == 0){
            label_state.text = "結清"
            field_payer.placeholder = "墊款人"
        }else{
            label_state.text = "入庫"
            field_payer.placeholder = "負責人"
        }
        if(!editMode){
            field_payer.placeholder = ""
        }
        if(image_photo.image == nil){
            self.btn_photo.layer.borderWidth = 1
            if(btn_photo.isEnabled){
                btn_photo.setTitle("Load Picture...", for: .normal)
            }else{
                btn_photo.setTitle("", for: .normal)
            }
        }else{
            self.btn_photo.layer.borderWidth = 0
            btn_photo.setTitle("", for: .normal)
        }
    }
    
    func enableFields(_ state: Bool){
        editMode = state
        field_io.isEnabled = state
        field_date.setEnable(state)
        field_name.setEnable(state)
        field_name.setEnable(state)
        field_sort.setEnable(state)
        field_state.isEnabled = state
        field_payer.setEnable(state)
        field_receipt.isEnabled = state
        field_amount.setEnable(state)
        btn_photo.isEnabled = state
        if(state){
            btn_photo.setTitle("Load Picture...", for: .normal)
            field_payer.placeholder = field_io.selectedSegmentIndex == 0 ? "墊款人" : "負責人"
        }else{
            btn_photo.setTitle("", for: .normal)
            field_payer.placeholder = ""
        }
    }
    
    func clearFields(){
        field_io.selectedSegmentIndex = 0
        field_date.text = ""
        field_name.text = ""
        field_sort.text = ""
        field_state.isOn = false
        field_payer.text = ""
        field_receipt.isOn = false
        field_amount.text = ""
        image_photo.image = nil
    }
    
    func validateField() -> Bool{
        if(field_date.text==""||field_name.text==""||field_amount.text==""){
            DialogService(self).showDialog_failed("部分欄位不允許為空", nil)
            return false
        }else{
            return true
        }
    }
    func addNewItem(){
        if(validateField()){
            addItem2List()
            clearFields()
            self.navigationController?.popViewController(animated: false)
            DialogService(self).showDialog_done("新增成功!",nil)
        }
    }
    //*************** MyData ***************//
    func addItem2List(){
        var amount = (field_amount.text?.floatValue)!
        if(field_io.selectedSegmentIndex==0){ amount *= -1 }
        let url = image_photo.image?.saveImageToLocal()
        let item = DS.Item(
            id: 0,
            date: field_date.text,
            name: field_name.text,
            sort: field_sort.text,
            state: field_state.isOn,
            payer: field_payer.text,
            reimburse: false,
            receipt: field_receipt.isOn || field_io.selectedSegmentIndex == 1,
            amount: amount,
            path: (url ?? "")
            //path: localPathStr
        )
        //currentSheetIndex
        DM.addItem(sheetIdx: AppDelegate.currentSheetIdx!, item: item)
    }
    func editItem2List(_ index: Int) {}
    
    func deleteItem2List(_ index: Int) {}
    
    //*************** Signal Function ***************//
    @objc func switchChanged() {
        uiChange()
    }
    
    @IBAction func btn_add(_ sender: Any) {
        addNewItem()
    }
    @objc func loadPhoto(){
        PhotoHandler.shared.showActionSheet(vc: self)
        PhotoHandler.shared.imagePickedBlock = { (image) in
            self.image_photo.image = image
        }
    }
    //*************** UiViewController ***************//
    override func viewDidLoad() {
        super.viewDidLoad()
        uiInit()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setFloatingButton()
        uiChange()
    }
    //*************** UITextFieldDelegate ***************//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
