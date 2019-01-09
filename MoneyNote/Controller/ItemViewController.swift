import UIKit
import Lightbox
class ItemViewController: UITableViewController, UITextFieldDelegate, MyUiProtocol, MyDataProtocol {
    
    @IBOutlet weak var field_io: UISegmentedControl!
    @IBOutlet weak var field_date: UITextField!
    @IBOutlet weak var field_name: UITextField!
    @IBOutlet weak var field_sort: UITextField!
    @IBOutlet weak var field_state: UISwitch!
    @IBOutlet weak var field_payer: UITextField!
    @IBOutlet weak var field_receipt: UISwitch!
    @IBOutlet weak var field_amount: UITextField!
    @IBOutlet weak var label_state: UILabel!
    @IBOutlet weak var btn_photo: UIButton!
    @IBOutlet weak var btn_usual_name: UIButton!
    @IBOutlet weak var tablecell_payer: UIView!
    @IBOutlet weak var tablecell_receipt: UITableViewCell!
    @IBOutlet weak var tablecell_photo: UIView!
    @IBOutlet weak var image_photo: UIImageView!
    
//*************** My Variable ***************//
    enum Mode{
        case view
        case edit
        case new
    }
    var mode: Mode = .view
    var datePickerService: DatePickerServic?
    var image: UIImage? = nil
    var quickFillTargetTag = 0
    var photo_edited = false
    
//*************** MyUi ***************//
    func setFloatingButton(){
        if(mode == .view){
            _ = AppDelegate.floatingButtons[0]!.set(text: "ㄑ"){
                self.navigationController?.popViewController(animated: false)
            }
            _ = AppDelegate.floatingButtons[1]!.set(text: ""){}
            _ = AppDelegate.floatingButtons[2]!.set(text: "✎"){
                self.toggleMode()
            }
        }else{
            _ = AppDelegate.floatingButtons[0]!.set(text: "✖"){
                if(self.mode == .new){
                    self.navigationController?.popViewController(animated: false)
                }else{
                    self.cancelEdit()
                    AD.sideFilterVC?.hide()
                }
            }
            _ = AppDelegate.floatingButtons[1]!.set(text: ""){}
            _ = AppDelegate.floatingButtons[2]!.set(text: "✔"){
                if(self.mode == .new){
                    self.addNewItem()
                }else{
                    self.toggleMode()
                }
            }
        }
    }
    func setSideConfig(){
        let top = UIApplication.shared.statusBarFrame.height
        let bottom = AppDelegate.toolBarHeight
        
        if(AD.sideFilterVC == nil){
            AD.sideFilterVC = (storyboard?.instantiateViewController(withIdentifier: "SideFilterViewController") as! SideFilterViewController)
            AD.sideFilterVC?.setMargin(top: top, bottom: bottom)
            AD.sideFilterVC?.setRelation(position: .left, movement: .stay)
        }
        AD.sideFilterVC?.handler_filter = { filters in
            if(AD.sideFilterVC?.mode == .sort){
                self.field_sort.text = filters[0]
                self.field_amount.becomeFirstResponder()
                AD.sideFilterVC?.toggle(to: false)
            }else{
                self.field_payer.text = filters[0]
                AD.sideFilterVC?.toggle(to: false)
            }
            
        }
    }
    
    func uiInit(){
        //Press retuen to close keyboard
        self.hideKeyboardWhenTappedAround()
        self.field_name.delegate = self
        self.field_sort.delegate = self
        self.field_payer.delegate = self
        self.field_amount.delegate = self
        
        self.field_name.returnKeyType = .done
        self.field_sort.returnKeyType = .done
        self.field_payer.returnKeyType = .done
        self.field_amount.returnKeyType = .done
        self.field_date.tag = 0
        self.field_name.tag = 1
        self.field_sort.tag = 2
        self.field_amount.tag = 3
        self.field_payer.tag = 4
        
        //hide payer view_payer and picture
        uiChange()
        field_io.addAction(for: .valueChanged){ self.uiChange() }
        field_state.addAction(for: .valueChanged){ self.uiChange() }
        field_receipt.addAction(for: .valueChanged){ self.uiChange() }
        
        //photo button
        btn_photo.layer.borderWidth = 1
        btn_photo.layer.borderColor = UIColor.gray.cgColor
        
        //date picker dialog
        datePickerService = DatePickerServic(self, field_date).showDatePicker()
        
        //Photo Picker
        btn_photo.addAction(for: .primaryActionTriggered){
            if(self.mode == .view){
                self.viewPhoto()
            }else{
                self.loadPhoto()
            }
        }
        
        //set usual btn
        _ = btn_usual_name.setBlackText().setRoundStyle()
        btn_usual_name.addAction(for: .touchUpInside){
            UsualListViewController.targetTag = 1
            let controller: UsualListViewController = UIStoryboard(.Main).instantiateViewController()
            self.navigationController?.pushViewController(controller, animated: false)
        }
        
        //EditMode
        if(AppDelegate.currentItemIdx! >= 0){
            mode = .view
            setFieldData()
            enableFields(false)
        }else{
            mode = .new
        }
        
        //Auto Jump
        field_amount?.addDoneCancelToolbar(onDone: (target: self, action: #selector(jumpToPayer)))
        if(mode == .new){
            datePickerService?.doneHandler = {self.field_name.becomeFirstResponder()}
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            field_date.text = formatter.string(from: date)
            field_name.becomeFirstResponder()
        }
        
    }
    func uiChange(){
        if(field_io.selectedSegmentIndex == 0){
            label_state.text = "結清"
            field_payer.placeholder = "付款人"
        }else{
            label_state.text = "入庫"
            field_payer.placeholder = "負責人"
        }
        if(mode == .view){
            field_payer.placeholder = ""
        }
        if(image_photo.image == nil){
            self.btn_photo.layer.borderWidth = 1
            if(btn_photo.isEnabled && mode != .view){
                btn_photo.setTitle("Load Picture...", for: .normal)
            }else{
                btn_photo.setTitle("", for: .normal)
            }
        }else{
            self.btn_photo.layer.borderWidth = 0
            btn_photo.setTitle("", for: .normal)
        }
        image_photo.image = image
    }
    
    func setFieldData(){
        let item = DM.getCurrentItem()!
        if item.amount >= 0.0{
            field_io.selectedSegmentIndex = 1
            field_amount.text = String(item.amount)
        }else {
            field_io.selectedSegmentIndex = 0
            field_amount.text = String(-item.amount)
        }
        field_name.text = item.name
        field_date.text = item.date
        field_sort.text = item.sort
        field_state.isOn = item.state
        field_payer.text = item.payer
        field_receipt.isOn = item.receipt
        if let imageData = NSData(contentsOfFile: item.path){
            image_photo.image = UIImage(data: imageData as Data)!
            image = image_photo.image
        }
    }
    
    func enableFields(_ state: Bool){
        field_io.isEnabled = state
        field_date.setEnable(state)
        field_name.setEnable(state)
        field_name.setEnable(state)
        field_sort.setEnable(state)
        field_state.isEnabled = state
        field_payer.setEnable(state)
        field_receipt.isEnabled = state
        field_amount.setEnable(state)
        //btn_photo.isEnabled = state
        btn_usual_name.isHidden = !state
        if(state){
            btn_photo.setTitle("Load Picture...", for: .normal)
            field_payer.placeholder = field_io.selectedSegmentIndex == 0 ? "墊款人" : "負責人"
        }else{
            btn_photo.setTitle("", for: .normal)
            field_payer.placeholder = ""
        }
    }
    
    func clearFields(){
        //field_io.selectedSegmentIndex = 0
        field_date.text = ""
        field_name.text = ""
        field_sort.text = ""
        field_state.isOn = false
        field_payer.text = ""
        field_receipt.isOn = false
        field_amount.text = ""
        image_photo.image = nil
    }
    
    func validateField() -> Bool{
        if(field_date.text==""||field_name.text==""||field_amount.text==""){
            DialogService.showDialog_failed("部分欄位不允許為空", nil)
            return false
        }else if(Float(field_amount.text!)==0){
            DialogService.showDialog_failed("金額不得為零", nil)
            return false
        }else{
            return true
        }
    }
    func addNewItem(){
        if(validateField()){
            addItem2List()
            clearFields()
            self.navigationController?.popViewController(animated: false)
            DialogService.showDialog_done("新增成功!",nil)
        }
    }
    
    func toggleMode() {
        if(mode == .view){
            mode = .edit
            enableFields(true)
            setFloatingButton()
            uiChange()
        }else if(mode == .edit){
            if(validateField()){
                mode = .view
                let index = AppDelegate.currentItemIdx!
                editItem2List(index)
                enableFields(false)
                setFloatingButton()
                uiChange()
                DialogService.showDialog_done("修改成功!",nil){
                    //self.navigationController?.popViewController(animated: false)
                }
            }
        }
    }
    func cancelEdit() {
        mode = .view
        self.setFloatingButton()
        enableFields(false)
        self.navigationItem.rightBarButtonItem?.title = "Edit"
        self.navigationItem.rightBarButtonItem?.style = .plain
    }
    
//*************** MyData ***************//
    func addItem2List(){
        var amount = (field_amount.text?.floatValue)!
        if(field_io.selectedSegmentIndex==0 && amount > 0){ amount *= -1 }
        let url = image_photo.image?.saveImageToLocal()
        let sheetid = DM.getCurrentSheet()!.id
        let timestamp = Date().secondFrom1970()
        let item = DS.Item(
            id: String(sheetid)+String(timestamp),
            date: field_date.text,
            name: field_name.text,
            sort: field_sort.text,
            state: field_state.isOn,
            payer: field_payer.text,
            reimburse: false,
            receipt: field_receipt.isOn,
            amount: amount,
            path: (url ?? ""),
            timestamp: timestamp,
            delete: false
            //path: localPathStr
        )
        //currentSheetIndex
        DM.addItem(sheetIdx: AppDelegate.currentSheetIdx!, item: item)
    }
    func editItem2List(_ index: Int) {
        let index = AppDelegate.currentItemIdx!
        let item = DM.table[AppDelegate.currentSheetIdx!].items[index]
        var url: String = item.path
        if(photo_edited){
            url = image_photo.image?.saveImageToLocal() ?? ""
            self.photo_edited = false
        }
        var amount = (field_amount.text?.floatValue)!
        if(field_io.selectedSegmentIndex==0 && amount > 0){amount *= -1}
        let item_new = DS.Item(
            id: item.id,
            date: field_date.text,
            name: field_name.text,
            sort: field_sort.text,
            state: field_state.isOn,
            payer: field_payer.text,
            reimburse: false,
            receipt: field_receipt.isOn,
            amount: amount,
            path: url,
            timestamp: Date().secondFrom1970(),
            delete: false
        )
        DM.editItem(sheetIdx: AppDelegate.currentSheetIdx!, itemIdx: index, item: item_new)
    }
    
    func deleteItem2List(_ index: Int) {}
    
//*************** Signal Function ***************//
    func loadPhoto(){
        FloatingController.hide()
        PhotoHandler.shared.showActionSheet(vc: self){
            FloatingController.show()
        }
        //self.photo_edited = false
        PhotoHandler.shared.imagePickedBlock = { (image) in
            self.photo_edited = true
            self.image_photo.image = image
            self.image = image
            FloatingController.show()
        }
    }
    func viewPhoto(){
        if let image = self.image{
            let images = [
                LightboxImage(
                image: image,
                text: ""
                )
            ]
            // Create an instance of LightboxController.
            let controller = LightboxController(images: images)
            controller.footerView.isHidden = true
            
            // Set delegates.
            controller.pageDelegate = self
            controller.dismissalDelegate = self
            
            // Use dynamic background.
            controller.dynamicBackground = true
            
            // Present your controller.
            present(controller, animated: true, completion: nil)
        }
    }
    func prepareUsual(){
        if(UsualListViewController.targetTag==1){
            if(UsualListViewController.currentString != ""){
                field_name.text = UsualListViewController.currentString
            }
            UsualListViewController.targetTag = 0
            UsualListViewController.currentString = ""
        }
        if(UsualCollectionViewController.targetTag==1){
            if(UsualCollectionViewController.currentString != ""){
                field_name.text = UsualCollectionViewController.currentString
            }
            UsualCollectionViewController.targetTag = 0
            UsualCollectionViewController.currentString = ""
        }
    }
//*************** UiViewController ***************//
    override func viewDidLoad() {
        super.viewDidLoad()
        uiInit()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uiChange()
        setFloatingButton()
        prepareUsual()
        FloatingController.show()
        setSideConfig()
        AD.sideFilterVC?.belongTo(self)
        AD.sideFilterVC?.multiMode = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FloatingController.hide()
        AD.sideFilterVC?.hide()
    }
    
//*************** UITextFieldDelegate ***************//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if(mode == .new){
            if (self.field_sort.tag == textField.tag + 1){
                field_sort.becomeFirstResponder()
                AD.sideFilterVC?.toggle(to: true)
            }
            if (self.field_amount.tag == textField.tag + 1){
                self.field_amount.becomeFirstResponder()
            }
        }
        return false
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField.tag == 2){
            self.view.endEditing(true)
            AD.sideFilterVC?.setMode(.sort)
            AD.sideFilterVC?.open()
            return false
        }
        if(textField.tag == 4){
            self.view.endEditing(true)
            AD.sideFilterVC?.setMode(.user)
            AD.sideFilterVC?.open()
            return false
        }
        AD.sideFilterVC?.close()
        return true
    }
    @objc func jumpToPayer(){
        if(mode == .new){
            self.field_payer.becomeFirstResponder()
        }
    }
    
}


extension ItemViewController: LightboxControllerPageDelegate {
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        //print(page)
    }
}

extension ItemViewController: LightboxControllerDismissalDelegate {
    func lightboxControllerWillDismiss(_ controller: LightboxController) { }
}
