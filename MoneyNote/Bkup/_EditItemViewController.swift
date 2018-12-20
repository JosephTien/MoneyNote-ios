//
//  ItemViewController.swift
//  AccountSheet
//
//  Created by 田茂堯 on 2018/12/5.
//  Copyright © 2018 JTien. All rights reserved.
//

import UIKit

class _EditItemViewController: UITableViewController, UITextFieldDelegate, MyUiProtocol, MyDataProtocol {
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
    var photo_edited = false
    
    //*************** UITextFieldDelegate ***************//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
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
        
        //Set field data
        let item = DM.table[AppDelegate.currentSheetIdx!].items[AppDelegate.currentItemIdx!]
        if item.amount > 0.0{
            field_io.selectedSegmentIndex = 1
            field_amount.text = String(item.amount)
        }else {
            field_io.selectedSegmentIndex = 0
            field_amount.text = String(-item.amount)
        }
        field_name.text = item.name
        field_date.text = item.date
        field_sort.text = item.sort
        field_state.isOn = item.state
        field_payer.text = item.payer
        field_receipt.isOn = item.receipt
        if let imageData = NSData(contentsOfFile: item.path){
            image_photo.image = UIImage(data: imageData as Data)!
        }
        
        //disable fileds
        enableFields(false)
        
    }
    
    func uiChange(){
        //tablecell_payer.isHidden = field_io.selectedSegmentIndex == 1
        tablecell_receipt.isHidden = field_io.selectedSegmentIndex == 1
        tablecell_photo.isHidden = field_io.selectedSegmentIndex == 1 || !field_receipt.isOn
        //field_payer.isHidden = field_state.isOn
        if(!field_state.isOn){
            field_payer.text=""
        }
        if(field_io.selectedSegmentIndex == 0){
            label_state.text = "結清"
            field_payer.placeholder = "墊款人"
        }else{
            label_state.text = "入庫"
            field_payer.placeholder = "負責人"
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
        field_io.isEnabled = state
        field_date.isEnabled = state
        field_name.isEnabled = state
        field_sort.isEnabled = state
        field_state.isEnabled = state
        field_payer.isEnabled = state
        field_receipt.isEnabled = state
        field_amount.isEnabled = state
        btn_photo.isEnabled = state
        if(state){
            btn_photo.setTitle("Load Picture...", for: .normal)
        }else{
            btn_photo.setTitle("", for: .normal)
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
    }
    
    func validateField() -> Bool{
        if(field_date.text==""||field_name.text==""||field_amount.text==""){
            DialogService(self).showDialog_failed("部分欄位不允許為空", nil)
            return false
        }else{
            return true
        }
    }
    
    func setFloatingButton() {}
    //*************** MyData ***************//
    func addItem2List(){}
    func editItem2List(_ index: Int) {
        let index = AppDelegate.currentItemIdx!
        let item = DM.table[AppDelegate.currentSheetIdx!].items[index]
        var url: String = item.path
        if(!photo_edited){
            url = image_photo.image?.saveImageToLocal() ?? ""
        }
        var amount = (field_amount.text?.floatValue)!
        if(field_io.selectedSegmentIndex==0){amount *= -1}
        let item_new = DS.Item(
            id: item.id,
            date: field_date.text,
            name: field_name.text,
            sort: field_sort.text,
            state: field_state.isOn,
            payer: field_payer.text,
            reimburse: false,
            receipt: field_receipt.isOn || field_io.selectedSegmentIndex == 1,
            amount: amount,
            path: url,
            timestamp: 0,
            delete: false
        )
        DM.editItem(sheetIdx: AppDelegate.currentSheetIdx!, itemIdx: index, item: item_new)
    }
    
    func deleteItem2List(_ index: Int) {}
    //*************** Signal Function ***************//
    @objc func switchChanged() {
        uiChange()
    }
    @IBAction func switchEditMode(_ sender: Any) {
        if(self.navigationItem.rightBarButtonItem?.title=="Edit"){
            enableFields(true)
            self.navigationItem.rightBarButtonItem?.title="Done"
            self.navigationItem.rightBarButtonItem?.style = .done
        }else if(self.navigationItem.rightBarButtonItem?.title=="Done"){
            if(validateField()){
                let index = AppDelegate.currentItemIdx!
                editItem2List(index)
                self.navigationController?.popViewController(animated: true)
                DialogService(self).showDialog_done("修改成功!",nil)
            }
        }
    }
    @objc func loadPhoto(){
        photo_edited = false
        FloatingController.hide()
        PhotoHandler.shared.showActionSheet(vc: self){
            FloatingController.show()
        }
        PhotoHandler.shared.imagePickedBlock = { (image) in
            self.image_photo.image = image
            self.photo_edited = true
        }
    }
    //*************** System finction ***************//
    override func viewDidLoad() {
        super.viewDidLoad()
        uiInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uiChange()
    }

}
