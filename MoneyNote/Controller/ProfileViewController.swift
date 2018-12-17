//
//  ProfileViewController.swift
//  AccountSheet
//
//  Created by 田茂堯 on 2018/12/6.
//  Copyright © 2018 JTien. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {
    
    @IBOutlet weak var label_calculate: UILabel!
    @IBOutlet weak var label_wallet: UILabel!
 
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var btn_import: UIButton!
    @IBOutlet weak var btn_outport: UIButton!
    //************* my Variable **************
    var listPickerService: ListPickerServic?
    
    //************** Controller function **************
    override func viewDidLoad() {
        super.viewDidLoad()
        uiInit()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uiChange()
        setFloatingButton()
        calculate()
    }
    @IBAction func btn_import(_ sender: Any) {
    }
    @IBAction func btn_outport(_ sender: Any) {
    }
//************** My UI function **************
    func uiInit(){
        btn_import.layer.borderWidth = 1
        btn_import.layer.cornerRadius = 10
        btn_import.setTitleColor(UIColor.black, for: .normal)
        btn_outport.layer.borderWidth = 1
        btn_outport.layer.cornerRadius = 10
        btn_outport.setTitleColor(UIColor.black, for: .normal)
    }
    func uiChange(){
        label_name.text = DM.table[AppDelegate.currentSheetIdx!].sheet.name
    }
    
    func setFloatingButton(){
        _ = AppDelegate.floatingButtons[0]!.set(text: "ㄑ"){
            self.navigationController?.popToRootViewController(animated: false)
        }
        _ = AppDelegate.floatingButtons[1]!.set(text: "$"){
            self.navigationController?.popViewController(animated: false)
        }
        _ = AppDelegate.floatingButtons[2]!.set(text: ""){}
    }
    
    
    func calculate(){
        let sheetIdx = AppDelegate.currentSheetIdx!
        let (val_calculation,val_wallet) = DM.table[sheetIdx].calculate()
        label_calculate.text = String(val_calculation)
        if(val_calculation<0){
            label_calculate.textColor = UIColor.red
        }else{
            label_calculate.textColor = UIColor.black
        }
        label_wallet.text = String(val_wallet)
    }
    
}
