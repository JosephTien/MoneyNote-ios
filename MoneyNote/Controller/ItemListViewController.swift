import UIKit

class ItemListCell: UITableViewCell {
    
    @IBOutlet weak var cellcomp_state: UILabel!
    @IBOutlet weak var cellcomp_name: UILabel!
    @IBOutlet weak var cellcomp_price: UILabel!
    @IBOutlet weak var cellcomp_date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

class ItemListViewController: UITableViewController {
    

// -------------------- My Variable ----------------------
    static var share: ItemListViewController?
    
//--------------------- UI Function ----------------------
    func uiInit(){
        self.navigationItem.title = DM.table[AppDelegate.currentSheetIdx!].sheet.name
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
        _ = AppDelegate.floatingButtons[2]!.set(text: ""){}
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
        self.tableView.reloadData()
        uiChange()
        setFloatingButton()

    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            DM.deleteItem(sheetIdx: AppDelegate.currentSheetIdx!, itemIdx: indexPath.row)
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
    
    // MARK: - Table view data source

    // Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return DM.table[AppDelegate.currentSheetIdx!].items.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idx = indexPath.section - 1
        if(idx>=0){
            let sign_done: String = "☑"//"✔"
            let sign_receipt: String = "⌧"
            let sign_dollar: String = "☐"//"💲"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemListCell", for: indexPath) as? ItemListCell else {
                fatalError("The dequeued cell is not an instance of TableViewCell.")
            }
            let item = DM.table[AppDelegate.currentSheetIdx!].items[idx]
            let datestr: String = item.date!
            cell.cellcomp_date.text = String(datestr[5..<datestr.count])
            cell.cellcomp_name.text = item.name
            cell.cellcomp_price.text = String(item.amount)
            if(!item.receipt){
                cell.cellcomp_state.text = sign_receipt
            }else if(!item.state){
                cell.cellcomp_state.text = sign_dollar
            }else{
                cell.cellcomp_state.text = sign_done
            }
            setCellStyle(cell.contentView)
            return cell
        }else if(idx == -1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewItem", for: indexPath)
            setCellStyle(cell.contentView)
                        return cell
        }
        return UITableViewCell()
    }
    
    func setCellStyle(_ view: UIView){
        let f = view.frame
        let container = UIView(frame: CGRect(x: f.minX+10, y: f.minY, width: f.width-20, height: f.height))
        container.layer.cornerRadius = 5
        container.layer.borderWidth = 1
        container.setFloating()
        view.addSubview(container)
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.currentItemIdx = indexPath.section - 1
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
