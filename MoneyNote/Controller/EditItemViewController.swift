//
//  ItemViewController.swift
//  AccountSheet
//
//  Created by 田茂堯 on 2018/12/5.
//  Copyright © 2018 JTien. All rights reserved.
//

import UIKit


class EditItemViewController: NewItemViewController{
    
    @IBOutlet weak var overide_field_io: UISegmentedControl!
    @IBOutlet weak var overide_field_date: UITextField!
    @IBOutlet weak var overide_field_name: UITextField!
    @IBOutlet weak var overide_field_sort: UITextField!
    @IBOutlet weak var overide_field_state: UISwitch!
    @IBOutlet weak var overide_field_payer: UITextField!
    @IBOutlet weak var overide_field_receipt: UISwitch!
    @IBOutlet weak var overide_field_amount: UITextField!
    @IBOutlet weak var overide_label_state: UILabel!
    @IBOutlet weak var overide_btn_photo: UIButton!
    @IBOutlet weak var override_btn_usual_name: UIButton!
    @IBOutlet weak var override_btn_usual_sort: UIButton!
    
    @IBOutlet weak var overide_tablecell_payer: UIView!
    @IBOutlet weak var overide_tablecell_receipt: UITableViewCell!
    @IBOutlet weak var overide_tablecell_photo: UIView!
    @IBOutlet weak var overide_image_photo: UIImageView!
    
    //*************** My Variable ***************//
    var photo_edited = false
    //*************** UITextFieldDelegate ***************//
    
    //*************** MyUi ***************//
    func reallocate(){
        //reallocate
        field_io    = overide_field_io
        field_date  = overide_field_date
        field_name  = overide_field_name
        field_sort  = overide_field_sort
        field_state = overide_field_state
        field_payer = overide_field_payer
        field_receipt   = overide_field_receipt
        field_amount    = overide_field_amount
        label_state     = overide_label_state
        btn_photo       = overide_btn_photo
        btn_usual_name  = override_btn_usual_name
        btn_usual_sort  = override_btn_usual_sort
        tablecell_payer = overide_tablecell_payer
        tablecell_receipt   = overide_tablecell_receipt
        tablecell_photo     = overide_tablecell_photo
        image_photo         = overide_image_photo
    }
    
    func setFieldData(){
        let item = DM.table[AppDelegate.currentSheetIdx!].items[AppDelegate.currentItemIdx!]
        if item.amount >= 0.0{
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
            image = image_photo.image
        }
    }
    override func uiInit(){
        reallocate()
        super.uiInit()
        setFieldData()
        enableFields(false)
    }
    override func uiChange() {
        super.uiChange()
    }
    override func setFloatingButton(){
        if(self.navigationItem.rightBarButtonItem?.title=="Edit"){
            _ = AppDelegate.floatingButtons[0]!.set(text: "ㄑ"){
                self.navigationController?.popViewController(animated: false)
            }
            _ = AppDelegate.floatingButtons[1]!.set(text: ""){}
            _ = AppDelegate.floatingButtons[2]!.set(text: "✎"){
                self.toggleMode()
            }
        }else if(self.navigationItem.rightBarButtonItem?.title=="Done"){
            setFloatingButton2()
        }
    }
    func setFloatingButton2(){
        _ = AppDelegate.floatingButtons[0]!.set(text: "✖"){
            self.cancelEdit()
        }
        _ = AppDelegate.floatingButtons[1]!.set(text: ""){}
        _ = AppDelegate.floatingButtons[2]!.set(text: "✔"){
            self.toggleMode()
        }
    }
    func toggleMode() {
        if(self.navigationItem.rightBarButtonItem?.title=="Edit"){
            enableFields(true)
            self.navigationItem.rightBarButtonItem?.title="Done"
            self.navigationItem.rightBarButtonItem?.style = .done
            setFloatingButton2()
        }else if(self.navigationItem.rightBarButtonItem?.title=="Done"){
            if(validateField()){
                let index = AppDelegate.currentItemIdx!
                editItem2List(index)
                enableFields(false)
                self.navigationItem.rightBarButtonItem?.title="Edit"
                self.navigationItem.rightBarButtonItem?.style = .plain
                setFloatingButton()
                uiChange()
                DialogService(self).showDialog_done("修改成功!",nil){
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }
    }
    func cancelEdit() {
        self.setFloatingButton()
        enableFields(false)
        self.navigationItem.rightBarButtonItem?.title = "Edit"
        self.navigationItem.rightBarButtonItem?.style = .plain
    }
    //*************** MyData ***************//
    override func editItem2List(_ index: Int) {
        let index = AppDelegate.currentItemIdx!
        let item = DM.table[AppDelegate.currentSheetIdx!].items[index]
        var url: String = item.path
        if(!photo_edited){
            url = image_photo.image?.saveImageToLocal() ?? ""
        }
        var amount = (field_amount.text?.floatValue)!
        if(field_io.selectedSegmentIndex==0 && amount<0){amount *= -1}
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
            timestamp: Date().secondFrom1970(),
            delete: false
        )
        DM.editItem(sheetIdx: AppDelegate.currentSheetIdx!, itemIdx: index, item: item_new)
    }
    
    //*************** Signal Function ***************//
    @IBAction func switchEditMode(_ sender: Any) {
        toggleMode()
    }

    //*************** System finction ***************//
    
}
