import UIKit

class ItemListCell: UITableViewCell {
    static var simpleMode = false
    @IBOutlet weak var cellcomp_receipt: UILabel!
    @IBOutlet weak var cellcomp_state: UILabel!
    @IBOutlet weak var cellcomp_name: UILabel!
    @IBOutlet weak var cellcomp_price: UILabel!
    @IBOutlet weak var cellcomp_date: UILabel!
    @IBOutlet weak var width_state: NSLayoutConstraint!
    @IBOutlet weak var width_receipt: NSLayoutConstraint!
    
    let msgLabel = UILabel()
    var deleteLine = UIView()
    var container :UIView? = nil
    var item: DS.Item? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        container = setCellStyle()
        
        contentView.addSubview(msgLabel)
        msgLabel.frame = contentView.frame
        msgLabel.textAlignment = .center
        
        deleteLine = setDeleteLine()
        deleteLine.isHidden = true
        /*
        contentView.addSubview(deleteLine)
        deleteLine.layer.borderWidth = 1
        //deleteLine.frame.size = CGSize(width: contentView.frame.width, height: 2)
        deleteLine.setHeightConstrain(to: contentView, height: 2)
        //deleteLine.alignCenter(to: contentView)
        //deleteLine.fullWidth(to: contentView, space: 10)
        */
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setContent(){
        if let item = self.item{
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
            if(ItemListCell.simpleMode){
                cellcomp_state.text = ""
                cellcomp_receipt.text = ""
                width_state.constant = 0
                width_receipt.constant = 0
            }else{
                width_state.constant = 16
                width_receipt.constant = 16
            }
            deleteLine.isHidden = !item.delete
        }
    }
    func setContent(item: DS.Item){
        self.item = item
        setContent()
    }
    
    func showContent(){
        deleteLine.isHidden = true
    }
    
    func deleteContent(){
        deleteLine.isHidden = false
        /*
        cellcomp_state.text = ""
        cellcomp_name.text = ""
        cellcomp_price.text = ""
        cellcomp_date.text = ""
        cellcomp_receipt.text = ""
        msgLabel.text = "Deleted!"
        */
    }
    
}

class ItemListViewController: UITableViewController {
    
// -------------------- My Variable ----------------------
    static var share: ItemListViewController?
    var visableItems: [Int] = []
    var showDeleted = false
    var filters: [String] = []
    var showType: SideConfigViewController.ShowType = .all
    var sortMethod: SideConfigViewController.SortMethod = .none
    var sortAsc = true
    var sideConfigController: SideConfigViewController? = nil
    var sideFilterController: SideFilterViewController? = nil
//--------------------- UI Function ----------------------
    func uiInit(){
        self.navigationItem.title = DM.table[AppDelegate.currentSheetIdx!].sheet.name
        assignVisableItems()
    }
    func uiChange(){
        
    }
    func setSideConfig(){
        let top = UIApplication.shared.statusBarFrame.height
        let bottom = AppDelegate.toolBarHeight
        
        sideConfigController = (storyboard?.instantiateViewController(withIdentifier: "SideConfigViewController") as! SideConfigViewController)
        sideConfigController?.setMargin(top: top, bottom: bottom)
        sideConfigController?.setRelation(position: .right, movement: .shrink)
        sideConfigController?.handler_deleted = { state in
            self.toggleShowDeleted(to: state)
        }
        sideConfigController?.handler_sort = { state in
            self.sortMethod = state
            self.refreshList()
        }
        sideConfigController?.handler_io = { state in
            self.showType = state
            self.refreshList()
        }
        sideConfigController?.handler_asc = { state in
            self.sortAsc = state
            self.refreshList()
        }
        sideConfigController?.handler_filt = {
            self.sideFilterController?.toggle()
        }
        
        sideFilterController = (storyboard?.instantiateViewController(withIdentifier: "SideFilterViewController") as! SideFilterViewController)
        sideFilterController?.setMargin(top: top, bottom: bottom)
        sideFilterController?.setRelation(position: .left, movement: .stay)
        sideFilterController?.handler_filter = { filters in
            self.filters = filters
            self.refreshList()
            self.sideConfigController?.btn_filt.setTitle(" \(filters.count) filters ", for: .normal)
        }
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
        _ = AppDelegate.floatingButtons[2]!.set(text: "≣"){
            self.showSideMenuBar()
        }
    }
    func assignVisableItems(){
        visableItems = []
        for (idx, item) in DM.table[AppDelegate.currentSheetIdx!].items.enumerated(){
            var visable = true
            if (item.delete && !showDeleted){
                visable = false
            }
            if(showType == .income && item.amount < 0){
                visable = false
            }
            if(showType == .outcome && item.amount > 0){
                visable = false
            }
            if(!filters.isEmpty && !filters.contains(item.sort!)){
                visable = false
            }
            if(visable){
                visableItems.append(idx)
            }
        }
        sortList()
    }
    func sortList(){
        visableItems.sort(by: {idxa, idxb in
            let itema = DM.table[AppDelegate.currentSheetIdx!].items[idxa]
            let itemb = DM.table[AppDelegate.currentSheetIdx!].items[idxb]
            if sortMethod == .amount{
                let a = itema.amount
                let b = itemb.amount
                if(sortAsc){
                    if(a==b){
                        return idxa < idxb
                    }
                    return a<b
                }else{
                    if(a==b){
                        return idxa > idxb
                    }
                    return a>b
                }
            }
            var a: String
            var b: String
            switch sortMethod{
            case .date:
                a = itema.date!
                b = itemb.date!
            case .name:
                a = itema.name!
                b = itemb.name!
            default:
                a = String(idxa)
                b = String(idxb)
            }
            if(sortAsc){
                if(a==b){
                    return idxa < idxb
                }
                return a<b
            }else{
                if(a==b){
                    return idxa > idxb
                }
                return a>b
            }
        })
    }
    
    func refreshList(){
        self.assignVisableItems()
        self.tableView.reloadData()
    }
    func toggleShowDeleted(){
        self.showDeleted = !self.showDeleted
        toggleShowDeleted(to: self.showDeleted)
    }
    func toggleShowDeleted(to: Bool){
        self.showDeleted = to
        refreshList()
        //DialogService(self).showDialog_done((self.showDeleted ? "顯示":"隱藏") + "「已刪除項目」", nil)
    }
    func toggleCellMode(){
        for cell in tableView.visibleCells{
            if let customCell = cell as? ItemListCell {
                customCell.setContent()
            }
        }
    }
    func showSideMenuBar(){
        sideConfigController?.toggle()
        ItemListCell.simpleMode = sideConfigController!.isOn
        toggleCellMode()
        if(!(sideConfigController!.isOn)){
            sideFilterController?.toggle(to: false)
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
        setSideConfig()
    }
    override func viewWillAppear(_ animated: Bool) {
        refreshList()
        uiChange()
        setFloatingButton()
        FloatingController.show()
        
        sideConfigController?.create()
        sideFilterController?.create()
    }
    override func viewWillDisappear(_ animated: Bool) {
        FloatingController.hide()
        
        sideConfigController?.elimimate()
        sideFilterController?.elimimate()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let choosen = indexPath.section - 1
        if (choosen < 0) {return []}
        let idx = visableItems[choosen]
        var item = DM.table[AppDelegate.currentSheetIdx!].items[idx]
        if (item.delete) {
            let recover = UITableViewRowAction(style: .normal, title: "Recover") { (action, indexPath) in
                DM.recoverItem(sheetIdx: AppDelegate.currentSheetIdx!, itemIdx: idx)
                item.delete = false
                if let cell = tableView.cellForRow(at: indexPath) as! ItemListCell?{
                    cell.setContent(item: item)
                }
            }
            return [recover]
        }
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            DM.deleteItem(sheetIdx: AppDelegate.currentSheetIdx!, itemIdx: idx)
            if tableView.cellForRow(at: indexPath) as! ItemListCell? != nil{
            //if let cell = tableView.cellForRow(at: indexPath) as! ItemListCell?{
                //cell.setContent(item: item)
                item.delete = true
                if(!self.showDeleted){
                    self.visableItems.remove(at: choosen)
                    self.tableView.deleteSections([indexPath.section], with: .fade)
                    
                }
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
            cell.setContent(item: item)
            
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
