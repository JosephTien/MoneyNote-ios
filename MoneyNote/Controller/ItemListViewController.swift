import UIKit

class ItemListCell: UITableViewCell {
    
    @IBOutlet weak var cellcomp_receipt: UILabel!
    @IBOutlet weak var cellcomp_state: UILabel!
    @IBOutlet weak var cellcomp_name: UILabel!
    @IBOutlet weak var cellcomp_price: UILabel!
    @IBOutlet weak var cellcomp_date: UILabel!
    let msgLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msgLabel.frame = contentView.frame
        msgLabel.textAlignment = .center
        addSubview(msgLabel)
        setCellStyle()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setContent(item: DS.Item){
        let sign_done: String = "◈"//"✔"//"✓"
        let sign_receipt: String = "◇"//"✖"//•
        let sign_dollar: String = "○"//"◯💲"
        let sign_ok: String = "◉"
        
        let datestr: String = item.date!
        if datestr.count==10{
            cellcomp_date.text = String(datestr[5..<datestr.count])
        }
        cellcomp_name.text = item.name
        cellcomp_price.text = String(item.amount)
        if(!item.state){
            cellcomp_state.text = sign_dollar
        } else{
            cellcomp_state.text = sign_ok
        }
        if(!item.receipt){
            cellcomp_receipt.text = sign_receipt
        }else{
            cellcomp_receipt.text = sign_done
        }
        msgLabel.text = ""
    }
    
    func clearContent(){
        cellcomp_state.text = ""
        cellcomp_name.text = ""
        cellcomp_price.text = ""
        cellcomp_date.text = ""
        cellcomp_receipt.text = ""
        msgLabel.text = "Deleted!"
    }
}

class ItemListViewController: UITableViewController {
    

// -------------------- My Variable ----------------------
    static var share: ItemListViewController?
    var visableItems: [Int] = []
    var showDeleted = false
//--------------------- UI Function ----------------------
    func uiInit(){
        self.navigationItem.title = DM.table[AppDelegate.currentSheetIdx!].sheet.name
        assignVisableItems()
    }
    func uiChange(){
        
    }
    func setFloatingButton(){
        _ = AppDelegate.floatingButtons[0]!.set(text: "ㄑ"){
            self.navigationController?.popViewController(animated: false)
        }
        _ = AppDelegate.floatingButtons[1]!.set(text: "i"){
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowProfile") as?  ProfileViewController{
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        _ = AppDelegate.floatingButtons[2]!.set(text: ":"){
            self.showDeleted = !self.showDeleted
            if(self.showDeleted){
                DialogService(self).showDialog_done("顯示已刪除", nil)
            }else{
                DialogService(self).showDialog_done("隱藏已刪除", nil)
            }
            self.assignVisableItems()
            self.tableView.reloadData()
        }
    }
    func assignVisableItems(){
        visableItems = []
        for (idx, item) in DM.table[AppDelegate.currentSheetIdx!].items.enumerated(){
            if (!item.delete || showDeleted){
                visableItems.append(idx)
            }
        }
    }
    
// -------------------- Data function --------------------
    func dataInit(){
        ItemListViewController.share = self
    }
//------------- System function -----------------
    override func viewDidLoad() {
        super.viewDidLoad()
        uiInit()
        dataInit()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.assignVisableItems()
        self.tableView.reloadData()
        uiChange()
        setFloatingButton()
        FloatingController.show()
    }
    override func viewWillDisappear(_ animated: Bool) {
        FloatingController.hide()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let choosen = indexPath.section - 1
        if (choosen < 0) {return []}
        let idx = visableItems[choosen]
        let item = DM.table[AppDelegate.currentSheetIdx!].items[idx]
        if (item.delete) {
            let recover = UITableViewRowAction(style: .normal, title: "Recover") { (action, indexPath) in
                DM.recoverItem(sheetIdx: AppDelegate.currentSheetIdx!, itemIdx: idx)
                if let cell = tableView.cellForRow(at: indexPath) as! ItemListCell?{
                    cell.setContent(item: item)
                }
            }
            return [recover]
        }
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            DM.deleteItem(sheetIdx: AppDelegate.currentSheetIdx!, itemIdx: idx)
            if let cell = tableView.cellForRow(at: indexPath) as! ItemListCell?{
                cell.clearContent()
            }
            //hard delete
            //tableView.deleteSections([indexPath.section] , with: .fade)
            
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
    
    // MARK: - Table view data source

    // Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //return DM.table[AppDelegate.currentSheetIdx!].items.count + 1
        return visableItems.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let choosen = indexPath.section - 1
        if(choosen>=0){
            let idx = visableItems[choosen]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemListCell", for: indexPath) as? ItemListCell else {
                fatalError("The dequeued cell is not an instance of TableViewCell.")
            }
            let item = DM.table[AppDelegate.currentSheetIdx!].items[idx]
            if(item.delete){
                cell.clearContent()
            }else{
                cell.setContent(item: item)
            }
            cell.isHidden = (!self.showDeleted && item.delete)
            
            return cell
        }else if(choosen == -1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewItem", for: indexPath)
            return cell
        }
        return UITableViewCell()
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let choosen = indexPath.section - 1
        if(choosen<0){AppDelegate.currentItemIdx = -1}
        else {AppDelegate.currentItemIdx = visableItems[choosen]}
        let idx = AppDelegate.currentItemIdx!
        if(idx >= 0){
            let item = DM.table[AppDelegate.currentSheetIdx!].items[idx]
            if(item.delete){return}
        }
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemViewController") as? ItemViewController {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: false)
            }
        }
    }
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath:
        IndexPath) {
        AppDelegate.item = AppDelegate.items[indexPath.row]
        performSegue(withIdentifier: "ItemViewController", sender: nil)
    }
    */

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
