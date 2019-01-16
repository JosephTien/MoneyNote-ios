//
//  SideFilterViewController.swift
//  MoneyNote
//
//  Created by 田茂堯 on 2019/1/2.
//  Copyright © 2019 JTien. All rights reserved.
//

import UIKit

class SideFilterListCell: UITableViewCell{
    var button = UIButton()
    override func awakeFromNib() {
        super.awakeFromNib()
        button.frame = contentView.frame
        selectedBackgroundView = nil
        contentView.addSubview(button)
        button.setTitleColor(UIColor.black, for: .normal)
    }
}

class SideFilterViewController: SideViewController, UITableViewDelegate, UITableViewDataSource {

    enum Mode{
        case sort
        case user
    }
    var mode: Mode = .sort
    var multiMode = true
    
    var states: [Bool] = []
    var filters: [String] = []
    var list: [String] = []
    
    var handler_filter : (([String])->()) = {_ in }
    
    @IBOutlet weak var tableview: UITableView!
    
    //-----------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        view.backgroundColor = nil
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        windowColor = UIColor.white
        tableview.frame.size = view.frame.size
        setBorderStyle()
        setMode(.sort)
    }
    
    //-----------------------------------------------
    func setBorderStyle(){
        let borderView = UIView(frame: view.frame)
        borderView.frame.origin = CGPoint(x: 0, y: 0)
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor.black.cgColor
        borderView.layer.cornerRadius = 15
        view.addSubview(borderView)
        borderView.isUserInteractionEnabled = false
        
        view.layer.cornerRadius = 15
        tableview.layer.cornerRadius = 15
    }
    func setMode(_ mode: Mode){
        self.mode = mode
        reset()
        tableview.reloadData()
    }
    func addSort(){
        DialogService.showDialog_input("新增類別", nil){string in
            DM.addSort(string)
            self.reset()
            self.tableview.reloadData()
        }
    }
    func addUser(){
        DialogService.showDialog_input("新增人員", nil){string in
            DM.addUser(string)
            self.reset()
            self.tableview.reloadData()
        }
    }
    override func belongTo(_ primary: UIViewController) {
        super.belongTo(primary)
        reset()
        tableview.reloadData()
    }
    func reset(){
        if(mode == .sort){
            list = DM.usualList.sorts
        }
        if(mode == .user){
            list = DM.usualList.users
        }
        states = [Bool](repeating: false, count: list.count)
        filters = []
    }
    
    //-----------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idx = indexPath.row - 1
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideFilterListCell", for: indexPath) as! SideFilterListCell
        
        while(idx >= states.count){
            states.append(false)
        }
        var text = idx >= 0 ? list[idx] : "➕";
        if(idx>=0 && states[idx]){text = "[ \(text) ]"}
        cell.button.tag = idx
        cell.button.setTitle(text, for: .normal)
        if(cell.button.allTargets.count==0){
            cell.button.addTarget(self, action: #selector(onClick(btn:)), for: .touchUpInside)
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLong(_:)))
            cell.button.addGestureRecognizer(longGesture)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if(indexPath.section<1){return []}
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [delete]
    }
    
    @objc func onClick(btn: UIButton){
        let idx = btn.tag
        if(idx < 0){
            switch(mode){
            case .sort: addSort()
            case .user: addUser()
            }
            return
        }
        let text = list[idx]
        if(multiMode){
            if(states[idx]){
                btn.setTitle(text, for: .normal)
                states[idx] = false
                filters.removeAll(){str in
                    return str==text
                }
            }else{
                btn.setTitle("[ \(text) ]", for: .normal)
                states[idx] = true
                filters.append(text)
            }
        }else{
            reset()
            filters = [text]
        }
        handler_filter(filters)
    }
    
    @objc func onLong(_ sender : UIGestureRecognizer){
        let btn = sender.view as! UIButton
        let idx = btn.tag
        if(idx<0){return}
        DialogService.showDialog_comfirm("確定要刪除嗎？",""){
            switch(self.mode){
            case .sort: DM.deleteSort(idx)
            case .user: DM.deleteUser(idx)
            }
            self.list.remove(at: idx)
            self.reset()
            let indexPath = IndexPath(row: idx+1, section: 0)
            self.tableview.deleteRows(at: [indexPath], with: .fade)
            self.tableview.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

