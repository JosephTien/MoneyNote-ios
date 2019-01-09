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
        _ = setCellStyle()
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
            UsualListViewController.targetTag = 0
            UsualListViewController.currentString = ""
            self.navigationController?.popViewController(animated: false)
        }
        _ = AppDelegate.floatingButtons[1]!.set(text: "≈"){
            UsualListViewController.targetTag = 0
            UsualListViewController.currentString = ""
            UsualCollectionViewController.targetTag = 1
            let controller: UsualCollectionViewController = UIStoryboard(.Main).instantiateViewController()
            self.navigationController?.pushViewController(controller, animated: false)
        }
        _ = AppDelegate.floatingButtons[2]!.set(text: ""){}
    }
    func uiInit(){
        self.tableView.separatorStyle = .none
    }
    
    func addUsual(){
        DialogService.showDialog_input("新增常用字串", "(ex:雜費、結餘)"){string in
            DM.usualList.strings.append(string)
            DM.usualList.saveToFile()
            self.tableView.reloadData()
        }
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
}
