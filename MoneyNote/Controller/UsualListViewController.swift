//
//  UsualViewController.swift
//  MoneyNote
//
//  Created by 田茂堯 on 2018/12/20.
//  Copyright © 2018 JTien. All rights reserved.
//

import UIKit

class UsualListCell: UITableViewCell {
    let msgLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        msgLabel.frame = frame
        msgLabel.textAlignment = .center
        msgLabel.textColor = UIColor.black
        contentView.addSubview(msgLabel)
        setCellStyle()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

class UsualListViewController: UITableViewController {
    static var currentString = ""
    static var targetTag = 0
    
    func setFloatingButton(){
        _ = AppDelegate.floatingButtons[0]!.set(text: "ㄑ"){
            self.navigationController?.popViewController(animated: false)
        }
        _ = AppDelegate.floatingButtons[1]!.set(text: ""){}
        _ = AppDelegate.floatingButtons[2]!.set(text: ""){}
    }
    func uiInit(){
        self.tableView.separatorStyle = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setFloatingButton()
        FloatingController.show()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return DM.usualList.strings.count+1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsualListCell", for: indexPath) as! UsualListCell
        
        if (indexPath.section==0){
            cell.msgLabel.text = "➕"
        }else{
            cell.msgLabel.text = DM.usualList.strings[indexPath.section-1]
        }
        // Configure the cell...
        return cell
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if(indexPath.section<1){return []}
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            DM.usualList.strings.remove(at: indexPath.section-1)
            DM.usualList.saveToFile()
            tableView.deleteSections([indexPath.section], with: .fade)
        }
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section<1){
            addUsual()
            return
        }
        UsualListViewController.currentString = DM.usualList.strings[indexPath.section-1]
        navigationController!.popViewController(animated: false)
    }
    
    
    func addUsual(){
        let alertController = UIAlertController(
            title: "新增常用字串",
            message: "(ex:雜費、結餘)",
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
                    FloatingController.show()
                }
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: "確定",
                style: UIAlertAction.Style.default
            ){(action: UIAlertAction!) -> Void in
                let string = tf.text!
                if(string == ""){
                    DialogService(self).showDialog_failed("不允許為空", nil)
                    return
                }
                DM.usualList.strings.append(string)
                DM.usualList.saveToFile()
                self.tableView.reloadData()
                FloatingController.show()
            }
        )
        FloatingController.hide()
        self.present(
            alertController,
            animated: true,
            completion: nil
        )
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
