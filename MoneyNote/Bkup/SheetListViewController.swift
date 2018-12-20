//
//  SheetsViewController.swift
//  AccountSheet
//
//  Created by 田茂堯 on 2018/12/12.
//  Copyright © 2018 JTien. All rights reserved.
//

import UIKit

class SheetListCell: UITableViewCell{
    
    @IBOutlet weak var cellcomp_name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

class SheetListViewController: UITableViewController {

//--------------------- My Variable ----------------------
    static var share: SheetListViewController?
    
//--------------------- UI Function ----------------------
    func uiInit(){
        
    }
    
    @IBAction func addNewSheet(_ sender: Any) {
        let alertController = UIAlertController(
            title: "新增",
            message: "請輸入帳務表單名稱",
            preferredStyle: .alert)
        
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "帳務表單"
        }
        let tf = ((alertController.textFields?.first)! as UITextField)
        alertController.addAction(
            UIAlertAction(
                title: "取消",
                style: .cancel,
                handler: nil
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: "確定",
                style: UIAlertAction.Style.default
            ){(action: UIAlertAction!) -> Void in
                let name = tf.text!
                if(name == ""){
                    DialogService(self).showDialog_failed("不允許為空", nil)
                    return
                }
                let id  = Int(Date().timeIntervalSince1970)
                let sheet = DS.Sheet(
                    id: id,
                    name: name,
                    spreadSheet: "",
                    lastSyncTime: ""
                )
                DM.addSheet(sheet: sheet)
                self.tableView.reloadData()
            }
        )
        
        self.present(
            alertController,
            animated: true,
            completion: nil
        )
    }
// -------------------- Data function --------------------
    func dataInit(){
        SheetListViewController.share = self
    }
// -------------------- System function --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        dataInit()
        uiInit()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DM.table.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SheetListCell", for: indexPath) as! SheetListCell
        cell.cellcomp_name.text = DM.table[indexPath.row].sheet.name

        return cell
    }
 
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            DM.deleteSheet(sheetIdx: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [delete]
        /*
         let share = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
         // share item at indexPath
         }
         share.backgroundColor = UIColor.lightGray
         return [delete, share]
         */
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.currentSheetIdx = indexPath.row
    }
    
    override func tableView(_ tableView: UITableView,
                            accessoryButtonTappedForRowWith indexPath: IndexPath){
        AppDelegate.currentSheetIdx = indexPath.row
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
