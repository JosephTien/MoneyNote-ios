//
//  SideFilterViewController.swift
//  MoneyNote
//
//  Created by 田茂堯 on 2019/1/2.
//  Copyright © 2019 JTien. All rights reserved.
//

import UIKit

class SideFilterViewController: SideViewController, UITableViewDelegate, UITableViewDataSource {

    var buttons = [UIButton?](repeating: nil, count: DM.usualList.sorts.count)
    var states = [Bool](repeating: false, count: DM.usualList.sorts.count)
    var filters: [String] = []
    var handler_filter : (([String])->()) = {filters in }
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        windowColor = UIColor.white
        setBorderStyle()
        
        buttons = [UIButton?](repeating: nil, count: DM.usualList.sorts.count)
        states = [Bool](repeating: false, count: DM.usualList.sorts.count)
    }
    
    func setBorderStyle(){
        let borderView = UIView(frame: view.frame)
        borderView.frame.origin = CGPoint(x: 0, y: 0)
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor.black.cgColor
        borderView.layer.cornerRadius = 15
        view.addSubview(borderView)
        borderView.isUserInteractionEnabled = false
    }
    /*
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
     */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DM.usualList.sorts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idx = indexPath.row
        let text = DM.usualList.sorts[idx]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideFilterCell", for: indexPath)
        if buttons[idx]==nil{
            let btn = UIButton(frame: cell.contentView.frame)
            btn.setTitle(text, for: .normal)
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.addTarget(self, action: #selector(onClick(btn:)), for: .touchUpInside)
            btn.tag = idx
            cell.contentView.addSubview(btn)
            buttons[idx] = btn
        }
        cell.selectedBackgroundView = nil
        return cell
    }
    @objc func onClick(btn: UIButton){
        let idx = btn.tag
        let text = DM.usualList.sorts[idx]
        if(states[idx]){
            btn.setTitle(text, for: .normal)
            states[idx] = false
            filters.removeAll(){str in
                return str==text
            }
            handler_filter(filters)
        }else{
            btn.setTitle("[ \(text) ]", for: .normal)
            states[idx] = true
            filters.append(text)
            handler_filter(filters)
        }
        print(filters)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

