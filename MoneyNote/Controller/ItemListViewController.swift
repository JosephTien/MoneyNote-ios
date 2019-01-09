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
    
    @IBOutlet weak var space1: NSLayoutConstraint!
    @IBOutlet weak var space3: NSLayoutConstraint!
    @IBOutlet weak var space2: NSLayoutConstraint!
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
                space1.constant = 8
                space2.constant = 0
                space3.constant = 0
            }else{
                width_state.constant = 16
                width_receipt.constant = 16
                space1.constant = 8
                space2.constant = 8
                space3.constant = 8
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
    
    var sorts: [String] = []
    var users: [String] = []
    var showType: SideConfigViewController.ShowType = .all
    var arrangeMethod: SideConfigViewController.ArrangeMethod = .none
    var stateType: SideConfigViewController.StateType = .all
    var sortAsc = true
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
        
        if(AD.sideConfigVC == nil){
            AD.sideConfigVC = (UIStoryboard(.Main).instantiateViewController())
            AD.sideConfigVC?.setMargin(top: top, bottom: bottom)
            AD.sideConfigVC?.setRelation(position: .right, movement: .shrink)
            AD.sideConfigVC?.handler_deleted = { state in
                self.showDeleted = state
                self.refreshList()
            }
            AD.sideConfigVC?.handler_sort = { state in
                self.arrangeMethod = state
                self.refreshList()
            }
            AD.sideConfigVC?.handler_io = { state in
                self.showType = state
                self.refreshList()
            }
            AD.sideConfigVC?.handler_state = { state in
                self.stateType = state
                self.refreshList()
            }
            AD.sideConfigVC?.handler_asc = { state in
                self.sortAsc = state
                self.refreshList()
            }
            AD.sideConfigVC?.handler_filt_sort = {
                if(AD.sideFilterVC?.mode == .user){
                    AD.sideFilterVC?.toggle(to: false, sec: 0.1){
                        AD.sideFilterVC?.setMode(.sort)
                        AD.sideFilterVC?.open()
                    }
                }else{
                    AD.sideFilterVC?.toggle()
                }
            }
            AD.sideConfigVC?.handler_filt_user = {
                if(AD.sideFilterVC?.mode == .sort){
                    AD.sideFilterVC?.toggle(to: false, sec: 0.1){
                        AD.sideFilterVC?.setMode(.user)
                        AD.sideFilterVC?.toggle(to: true)
                    }
                }else{
                    AD.sideFilterVC?.toggle()
                }
            }
        }
        if(AD.sideFilterVC == nil){
            AD.sideFilterVC = UIStoryboard(.Main).instantiateViewController()
            AD.sideFilterVC?.setMargin(top: top, bottom: bottom)
            AD.sideFilterVC?.setRelation(position: .left, movement: .stay)
        }
        AD.sideFilterVC?.handler_filter = { filters in
            if(AD.sideFilterVC?.mode == .sort){
                self.sorts = filters
                self.refreshList()
                if(filters.count==0){
                    AD.sideConfigVC?.btn_sort.setTitle(" all sort ", for: .normal)
                }else if (filters.count==1){
                    AD.sideConfigVC?.btn_sort.setTitle(" 1 sort ", for: .normal)
                }else{
                    AD.sideConfigVC?.btn_sort.setTitle(" \(filters.count) sorts ", for: .normal)
                }
            }
            if(AD.sideFilterVC?.mode == .user){
                self.users = filters
                self.refreshList()
                if(filters.count==0){
                    AD.sideConfigVC?.btn_user.setTitle(" all user ", for: .normal)
                }else if (filters.count==1){
                    AD.sideConfigVC?.btn_user.setTitle(" 1 user ", for: .normal)
                }else{
                    AD.sideConfigVC?.btn_user.setTitle(" \(filters.count) users ", for: .normal)
                }
            }
            
        }
    }
    func setFloatingButton(){
        _ = AppDelegate.floatingButtons[0]!.set(text: "ㄑ"){
            self.navigationController?.popViewController(animated: false)
        }
        _ = AppDelegate.floatingButtons[1]!.set(text: "i"){
            let vc: ProfileViewController = UIStoryboard(.Main).instantiateViewController()
            self.navigationController?.pushViewController(vc, animated: false)
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
            if((stateType == .noReceipt || stateType == .bad) && item.receipt){
                visable = false
            }
            if((stateType == .notPaid || stateType == .bad) && item.state){
                visable = false
            }
            if(!sorts.isEmpty && !sorts.contains(item.sort!)){
                visable = false
            }
            if(!users.isEmpty && !users.contains(item.payer!)){
                visable = false
            }
            if(visable){
                visableItems.append(idx)
            }
        }
        arrangeList()
    }
    func arrangeList(){
        visableItems.sort(by: {idxa, idxb in
            let itema = DM.table[AppDelegate.currentSheetIdx!].items[idxa]
            let itemb = DM.table[AppDelegate.currentSheetIdx!].items[idxb]
            if arrangeMethod == .amount{
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
            switch arrangeMethod{
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
    
    func toggleCellMode(_ simpleMode: Bool){
        ItemListCell.simpleMode = simpleMode
        for cell in tableView.visibleCells{
            if let customCell = cell as? ItemListCell {
                customCell.setContent()
            }
        }
    }
    func showSideMenuBar(){
        AD.sideConfigVC?.toggle()
        self.toggleCellMode(AD.sideConfigVC!.isOn)
        if(!(AD.sideConfigVC!.isOn)){
            AD.sideFilterVC?.toggle(to: false)
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
        super.viewWillAppear(animated)
        refreshList()
        uiChange()
        setFloatingButton()
        FloatingController.show()
        
        setSideConfig()
        AD.sideConfigVC?.belongTo(self)
        AD.sideFilterVC?.belongTo(self)
        AD.sideFilterVC?.multiMode = true
        AD.sideFilterVC?.setMode(.sort)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FloatingController.hide()
        
        AD.sideConfigVC?.hide()
        AD.sideFilterVC?.hide()
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
        }
        return [delete]
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
        if let viewController = UIStoryboard(.Main).instantiateViewController(withIdentifier: "ItemViewController") as? ItemViewController {
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
