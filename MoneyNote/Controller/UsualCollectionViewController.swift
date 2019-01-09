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
            UsualCollectionViewController.targetTag = 0
            UsualCollectionViewController.currentString = ""
            self.navigationController?.popViewController(animated: false)
            self.navigationController?.popViewController(animated: false)
        }
        _ = AppDelegate.floatingButtons[1]!.set(text: "≈"){
            UsualCollectionViewController.targetTag = 0
            UsualCollectionViewController.currentString = ""
            UsualListViewController.targetTag = 1
            self.navigationController?.popViewController(animated: false)
        }
        _ = AppDelegate.floatingButtons[2]!.set(text: ""){}
    }
    
    func uiInit(){
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
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
                    DialogService.showDialog_failed("不允許為空", nil)
                    return
                }
                DM.usualList.strings.append(string)
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
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                let index = indexPath.item - 1
                if(index < 0){return}
                DialogService.showDialog_comfirm("確定要刪除嗎？",""){
                    DM.usualList.strings.remove(at: index)
                    self.collectionView.deleteItems(at: [indexPath])
                }
            }
        }
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return DM.usualList.strings.count+1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UsualCollectCell
    
        if (indexPath.item==0){
            cell.msgLabel.text = "➕"
        }else{
            cell.msgLabel.text = DM.usualList.strings[indexPath.item-1]
        }
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.item<1){
            addUsual()
            return
        }
        UsualCollectionViewController.currentString = DM.usualList.strings[indexPath.item-1]
        navigationController!.popViewController(animated: false)
        navigationController!.popViewController(animated: false)
    }
}
