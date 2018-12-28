import UIKit

class UsualCollectionViewLayout:UICollectionViewFlowLayout{
    
    override func awakeFromNib() {
        self.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        
        self.minimumLineSpacing = 5
        
        self.itemSize = CGSize(
            width: CGFloat(screenWidth)/2 - 10.0,
            height: CGFloat(screenWidth)/32*5 - 10.0)
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

class UsualCollectCell: UICollectionViewCell {
    let msgLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        //selectionStyle = .none
        msgLabel.frame = contentView.frame
        msgLabel.textAlignment = .center
        msgLabel.textColor = UIColor.black
        contentView.addSubview(msgLabel)
        setCellStyle()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private let reuseIdentifier = "UsualCollectionCell"

class UsualCollectionViewController: UICollectionViewController {
    
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
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UsualCollectCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        uiInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setFloatingButton()
        FloatingController.show()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return DM.usualList.sorts.count+1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UsualCollectCell
    
        if (indexPath.item==0){
            cell.msgLabel.text = "➕"
        }else{
            cell.msgLabel.text = DM.usualList.sorts[indexPath.item-1]
        }
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.item<1){
            addUsual()
            return
        }
        UsualCollectionViewController.currentString = DM.usualList.sorts[indexPath.item-1]
        navigationController!.popViewController(animated: false)
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                let index = indexPath.item - 1
                if(index < 0){return}
                DialogService(self).showDialog_comfirm("確定要刪除嗎？",""){
                    DM.usualList.sorts.remove(at: index)
                    self.collectionView.deleteItems(at: [indexPath])
                }
            }
        }
    }
    
    func addUsual(){
        let alertController = UIAlertController(
            title: "新增類別",
            message: "",
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
                DM.usualList.sorts.append(string)
                DM.usualList.saveToFile()
                self.collectionView.reloadData()
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
