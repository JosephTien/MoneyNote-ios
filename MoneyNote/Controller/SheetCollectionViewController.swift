import UIKit

private let reuseIdentifiers = ["SheetCollectionCell", "SheetCollectionAddCell"]


class SheetCollectionViewLayout:UICollectionViewFlowLayout{
    
    override func awakeFromNib() {
        self.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        
        self.minimumLineSpacing = 5
        
        self.itemSize = CGSize(
            width: CGFloat(screenWidth)/2 - 10.0,
            height: CGFloat(screenWidth)/32*10 - 10.0) // 16:10
        //headerReferenceSize = CGSize()
        //footerReferenceSize = CGSize()
    }
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
}

class SheetCollectionAddCell: UICollectionViewCell{
    var cellcomp_add:UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAddIcon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setAddIcon(){
        let h = self.bounds.height
        let w = self.bounds.width
        cellcomp_add = UILabel(frame:CGRect(x: 0, y: h/3, width: w, height: h/3))
        cellcomp_add.textAlignment = .center
        cellcomp_add.textColor = UIColor.black
        cellcomp_add.text = "➕"
        self.addSubview(cellcomp_add)
    }

}

class SheetCollectionCell: UICollectionViewCell{
    
    var cellcomp_title:UILabel!
    var cellcomp_count:UILabel!
    var cellcomp_cash:UILabel!
    var cellcomp_text_count:UILabel!
    var cellcomp_text_cash:UILabel!
    var cellcomp_paid:UILabel!
    var cellcomp_text_paid:UILabel!
    var cellcomp_receipt:UILabel!
    var cellcomp_text_receipt:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setContext()
    }
  
    func setContext(){
        let h = self.bounds.height
        let w = self.bounds.width
        
        cellcomp_title = UILabel(frame:CGRect(x: 0, y: 0, width: w, height: h/4))
        cellcomp_title.textAlignment = .center
        cellcomp_title.textColor = UIColor.black
        cellcomp_title.font = UIFont.boldSystemFont(ofSize: 16)
        
        cellcomp_count = UILabel(frame:CGRect(x: 0, y: h/4, width: w-9, height: h/4))
        cellcomp_count.textAlignment = .right
        //cellcomp_count.textColor = UIColor.blue
        cellcomp_count.textColor = UIColor.black
        
        cellcomp_cash = UILabel(frame:CGRect(x: 0, y: h/4*2, width: w-9, height: h/4))
        cellcomp_cash.textAlignment = .right
        //cellcomp_cash.textColor = UIColor.blue
        cellcomp_count.textColor = UIColor.black
        
        cellcomp_text_count = UILabel(frame:CGRect(x: 9, y: h/4, width: w-9, height: h/4))
        cellcomp_text_count.textAlignment = .left
        cellcomp_text_count.textColor = UIColor.black
        cellcomp_text_count.text = "小計："
        
        cellcomp_text_cash = UILabel(frame:CGRect(x: 9, y: h/4*2, width: w-9, height: h/4))
        cellcomp_text_cash.textAlignment = .left
        cellcomp_text_cash.textColor = UIColor.black
        cellcomp_text_cash.text = "現金："
        
        //-------------------------------------------
        
        cellcomp_paid = UILabel(frame:CGRect(x: 9, y: h/4*3, width: (w-9)/4, height: h/4))
        cellcomp_paid.textAlignment = .right
        //cellcomp_count.textColor = UIColor.blue
        cellcomp_paid.textColor = UIColor.black
        
        cellcomp_receipt = UILabel(frame:CGRect(x: 9 + (w-9)/2, y: h/4*3, width: (w-9)/4, height: h/4))
        cellcomp_receipt.textAlignment = .right
        //cellcomp_cash.textColor = UIColor.blue
        cellcomp_receipt.textColor = UIColor.black
        
        cellcomp_text_paid = UILabel(frame:CGRect(x: 9 + (w-9)/4, y: h/4*3, width: (w-9)/4, height: h/4))
        
        cellcomp_text_paid.textAlignment = .left
        cellcomp_text_paid.textColor = UIColor.black
        cellcomp_text_paid.text = " ○"
        
        cellcomp_text_receipt = UILabel(frame:CGRect(x: 9 + (w-9)/4*3, y: h/4*3, width: (w-9)/4, height: h/4))
        
        cellcomp_text_receipt.textAlignment = .left
        cellcomp_text_receipt.textColor = UIColor.black
        cellcomp_text_receipt.text = " ◇"
        
        
        self.addSubview(cellcomp_title)
        self.addSubview(cellcomp_count)
        self.addSubview(cellcomp_cash)
        self.addSubview(cellcomp_text_count)
        self.addSubview(cellcomp_text_cash)
        self.addSubview(cellcomp_paid)
        self.addSubview(cellcomp_receipt)
        self.addSubview(cellcomp_text_paid)
        self.addSubview(cellcomp_text_receipt)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SheetCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
//
//--------------------- My Variable ----------------------
    static var share: SheetCollectionViewController?
    
    @IBOutlet var viewDetail: UILongPressGestureRecognizer!
    
    //--------------------- UI Function ----------------------
    func setToolBar(){//set here since it is the first controller instance
        let toolbar = self.navigationController!.toolbar!
        self.navigationController!.isToolbarHidden = false
        toolbar.backgroundColor = UIColor.white
        toolbar.setBackgroundImage(UIImage(),
                                   forToolbarPosition: .any,
                                   barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    func uiInit(){
        // Register cell classes
        self.collectionView!.register(SheetCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifiers[0])
        self.collectionView!.register(SheetCollectionAddCell.self, forCellWithReuseIdentifier: reuseIdentifiers[1])
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        setToolBar()
    }
    func uiChange(){
        self.collectionView.reloadData()
    }
    
    func setFloatingButton(){
        _ = AppDelegate.floatingButtons[0]!.set(text: ""){}
        _ = AppDelegate.floatingButtons[1]!.set(text: ""){}
        _ = AppDelegate.floatingButtons[2]!.set(text: ""){}
    }
    
    func addNewSheet() {
        let alertController = UIAlertController(
            title: "新增帳冊",
            message: "(ex:一月雜支、行銷活動)",
            preferredStyle: .alert)
        
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "帳冊名稱"
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
                    DialogService.showDialog_failed("不允許為空", nil)
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
                self.collectionView.reloadData()
            }
        )
        
        self.present(
            alertController,
            animated: true,
            completion: nil
        )
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                AppDelegate.currentSheetIdx = indexPath.item - 1
                if(AppDelegate.currentSheetIdx!<0){return}
                
                DialogService.showDialog_comfirm("確定要刪除嗎？",""){
                    DM.deleteSheet(sheetIdx: AppDelegate.currentSheetIdx!)
                    self.collectionView.deleteItems(at: [indexPath])
                }
            }
        }
    }
// -------------------- Data function --------------------
    func dataInit(){
        SheetCollectionViewController.share = self
    }
// -------------------- System function --------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        dataInit()
        uiInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        uiChange()
        setFloatingButton()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return DM.table.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let idx = indexPath.item - 1
        if(idx >= 0){
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifiers[0], for: indexPath) as? SheetCollectionCell  else {
                fatalError("The dequeued cell is not an instance of SheetCollectionCell.")
            }
            let (count, cash) = DM.table[idx].calculate()
            cell.cellcomp_title.text =  DM.table[idx].sheet.name
            cell.cellcomp_count.text = String(count)
            cell.cellcomp_cash.text = String(cash)
            let (notPaid, noReceipt) = DM.table[idx].statue()
            cell.cellcomp_paid.text = String(notPaid)
            cell.cellcomp_receipt.text = String(noReceipt)
            setCellStyle(cell)
            return cell
        }else if(idx == -1){
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifiers[1], for: indexPath) as? SheetCollectionAddCell  else {
                fatalError("The dequeued cell is not an instance of SheetCollectionAddCell.")
            }
            setCellStyle(cell)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func setCellStyle(_ view: UIView){
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.setFloating()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let idx = indexPath.item - 1
        if idx>=0{
            AppDelegate.currentSheetIdx = idx
            self.performSegue(withIdentifier: "ShowItemList", sender: self)
        }else{
            addNewSheet()
        }
    }
    /*
    override func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth / 2, height: screenWidth / 32 * 9)
    }
     */
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth / 2, height: screenWidth / 32 * 9)
    }
     */
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
class Toolbar: UIToolbar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize: CGSize = super.sizeThatFits(size)
        newSize.height = AppDelegate.toolBarHeight
        return newSize
    }
}
