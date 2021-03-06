import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class ProfileViewController: GSTableViewcontroller, UITextFieldDelegate{
    
    @IBOutlet weak var label_calculate: UITextField!
    @IBOutlet weak var label_wallet: UITextField!
    @IBOutlet weak var label_sync: UITextField!
    @IBOutlet weak var label_name: UITextField!
    @IBOutlet weak var btn_sync: UIButton!
    
    @IBOutlet weak var label_receipt: UITextField!
    
    @IBOutlet weak var btn_analysis: UIButton!
    @IBOutlet weak var label_paid: UITextField!
    //************* my Variable **************
    var listPickerService: ListPickerServic?
    var importSucceed = false
    var outportSucceed = false
    var qrAlert: UIAlertController?
    
//************** My UI function **************
    func uiInit(){
        setButtonStyle(btn_sync)
        setButtonStyle(btn_analysis)
        btn_analysis.addAction(for: .touchUpInside){
            DialogService.showDialog_done("to be continue...", nil)
        }
        label_calculate.setEnable(false)
        label_wallet.setEnable(false)
        label_sync.setEnable(false)
        //label_name.setEnable(false)
        label_name.delegate = self
        label_name.returnKeyType = .done
        label_name.addAction(for: .editingDidEnd){
            self.label_name.setEnable(true)
        }
    }
    
    func uiChange(){
        label_name.text = DM.table[AppDelegate.currentSheetIdx!].sheet.name
        if(DM.table[AppDelegate.currentSheetIdx!].sheet.spreadSheet != ""){
            if(DM.table[AppDelegate.currentSheetIdx!].sheet.lastSyncTime == ""){
                label_sync.text = "已連動，尚未同步"
            }else{
                label_sync.text = DM.table[AppDelegate.currentSheetIdx!].sheet.lastSyncTime
            }
        }else{
            label_sync.text = "尚未連動"
        }
    }
    
    func setButtonStyle(_ button: UIButton){
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        button.setTitleColor(UIColor.black, for: .normal)
    }
    
    func setFloatingButton(){
        _ = AppDelegate.floatingButtons[0]!.set(text: "ㄑ"){
            self.navigationController?.popToRootViewController(animated: false)
        }
        _ = AppDelegate.floatingButtons[1]!.set(text: "$"){
            self.navigationController?.popViewController(animated: false)
        }
        _ = AppDelegate.floatingButtons[2]!.set(text: "⎋"){
            self.showActionSheet()
        }
    }
    func unsetFloatingButton(){
        _ = AppDelegate.floatingButtons[0]!.set(text: ""){}
        _ = AppDelegate.floatingButtons[1]!.set(text: ""){}
        _ = AppDelegate.floatingButtons[2]!.set(text: ""){}
    }
    
    func calculate(){
        let sheetIdx = AppDelegate.currentSheetIdx!
        let (val_calculation,val_wallet) = DM.table[sheetIdx].calculate()
        label_calculate.text = String(val_calculation)
        label_calculate.textColor = UIColor.black
        label_wallet.text = String(val_wallet)
        
        let (notPaid, noReceipt) = DM.table[sheetIdx].statue()
        label_paid.text = String(notPaid)
        label_receipt.text = String(noReceipt)
    }
    
//************** Controller function **************
    override func viewDidLoad() {
        super.viewDidLoad()
        uiInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uiChange()
        calculate()
        setFloatingButton()
        FloatingController.show()
    }
    override func viewWillDisappear(_ animated: Bool) {
        unsetFloatingButton()
        FloatingController.hide()
    }
    @IBAction func btn_sync(_ sender: Any) {
        if(DM.table[AppDelegate.currentSheetIdx!].sheet.spreadSheet==""){
            DialogService.showDialog_ask("尚未連動", "現在開始進行連動嗎？若為第一次匯出，建議選擇創建新表單。"){
                self.showActionSheet()
            }
            return
        }
        FloatingController.hide()
        signIn(
            succeedHandler: { _ in
                FloatingController.show()
                self.syncSheet()
            },
            errorHandler: {
                FloatingController.show()
            }
        )
    }
    
//*************** UITextFieldDelegate ***************
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        DM.table[AppDelegate.currentSheetIdx!].sheet.name = label_name.text!
        DM.saveSheets()
        label_name.setEnable(false)
        return false
    }
    
//************** Data Maintain function **************
    func importSheet(after: @escaping ()->()){
        //FloatingController.cover(true)
        FloatingController.coverAndShow("IMPORTING...")
        fetchSheet(spreadsheetId: DM.table[AppDelegate.currentSheetIdx!].sheet.spreadSheet
            , succeedHandler: { rows in
                self.decodeRawData(rows as! [[String]])
            },
            finalHandler: {
                FloatingController.cover(false)
                after()
                print("Leave import")
            }
        )
    }
    
    func outportSheet(after: @escaping ()->()){
        //FloatingController.cover(true)
        FloatingController.coverAndShow("OUTPORTING...")
        updateSheet(spreadsheetId: DM.table[AppDelegate.currentSheetIdx!].sheet.spreadSheet,
            values: generateRawData(),
            succeedHandler: { _ in
                //DialogService.showDialog_done("成功匯出", ""){}
                //self.showAlert(title: "成功匯出", message: "")
                self.outportSucceed = true
            },
            finalHandler: {
                FloatingController.cover(false)
                after()
                print("Leave outport")
            }
        )
    }
    
    func syncSheet(){
        self.importSucceed = false
        self.importSheet(){
            if(!self.importSucceed){return}
            self.outportSucceed = false
            self.outportSheet(){
                if(!self.outportSucceed){return}
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
                let dateString = dateFormatter.string(from: currentDate)
                DM.table[AppDelegate.currentSheetIdx!].sheet.lastSyncTime = dateString
                self.label_sync.text = dateString
                DM.saveSheets()
                DialogService.showDialog_done("成功同步", "")
            }
        }
    }
    
    func addSync() {
        let enterController = UIAlertController(
            title: "輸入Google Sheet ID",
            message: "",
            preferredStyle: .alert)
        
        enterController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Google Sheet ID"
        }
        
        let tf = ((enterController.textFields?.first)! as UITextField)
        enterController.addAction(
            UIAlertAction(
                title: "取消",
                style: .cancel){(action: UIAlertAction!) -> Void in
                    FloatingController.show()
            }
        )
        enterController.addAction(
            UIAlertAction(
                title: "確定",
                style: UIAlertAction.Style.default,
                handler: {(action: UIAlertAction!) -> Void in
                    FloatingController.show()
                    let spreadsheetId = tf.text!
                    if(spreadsheetId == ""){
                        DialogService.showDialog_failed("不允許為空", nil)
                        return
                    }
                    DM.table[AppDelegate.currentSheetIdx!].sheet.spreadSheet = spreadsheetId
                    DM.saveSheets()
                    self.label_sync.text = "已連動，尚未同步"
                    DialogService.showDialog_ok("提示", "已連動Google Sheet，可以開始進行同步"){
                        DialogService.showDialog_ok("提醒", "您必須要有該表單的權限，且該表單必須符合自動生成的格式。"){}
                    }
                }
            )
        )
        
        DialogService.showDialog_ask("從剪貼簿複製ID？", ""){
            FloatingController.hide()
            tf.text = UIPasteboard.general.string
            self.present(
                enterController,
                animated: true,
                completion: nil
            )
        }
    }
    
    func createSheet(){
        FloatingController.hide()
        signIn(
            succeedHandler: { _ in
                FloatingController.show()
                let idx = AppDelegate.currentSheetIdx!
                FloatingController.coverAndShow("Creating...")
                self.createSheet(name: DM.table[idx].sheet.name,
                     succeedHandler: { spreadSheet in
                        DM.table[idx].sheet.spreadSheet = spreadSheet as! String
                        DS.Sheet.saveToFile(sheets: DM.getSheets())
                        self.label_sync.text = "已連動"
                        DM.saveSheets()
                        //self.showAlert(title: "Created!", message: "")
                        DialogService.showDialog_ok("提示", "已建立Google Sheet，可以開始進行同步"){}
                    },
                    finalHandler: {
                        FloatingController.cover(false)
                    }
                )
            },
            errorHandler: {
                FloatingController.show()
            }
        )
    }
    
    func showActionSheet() {
        FloatingController.hide()
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sheet = DM.getCurrentSheet()!
        if(sheet.spreadSheet != ""){
            actionSheet.addAction(UIAlertAction(title: "Open Spreadsheets", style: .default, handler: { (alert:UIAlertAction!) -> Void in
                FloatingController.show()
                guard let url = URL(string: "https://docs.google.com/spreadsheets/d/"+sheet.spreadSheet) else {
                    return //be safe
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Copy ID", style: .default, handler: { (alert:UIAlertAction!) -> Void in
                FloatingController.show()
                UIPasteboard.general.string = sheet.spreadSheet
                DialogService.showDialog_done("Copied","")
                //self.showAlert(title: "Copied", message: "")
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Show QRcode", style: .default, handler: { (alert:UIAlertAction!) -> Void in
                //FloatingController.show()
                DialogService.showDialog_ok("提示", "若要向他人分享帳冊，您必須至該Google Sheet的設定中將其Google Account加入為協作者，或是將共用模式設定為「知道連結的人皆可編輯」", function: {
                        self.showQRCode(sheet.spreadSheet)
                    })
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Unlink", style: .default, handler: { (alert:UIAlertAction!) -> Void in
                FloatingController.show()
                DM.table[AppDelegate.currentSheetIdx!].sheet.spreadSheet = ""
                self.label_sync.text = "尚未連動"
                DialogService.showDialog_done("Unlinked","")
                DM.saveSheets()
            }))
        }else{
            actionSheet.addAction(UIAlertAction(title: "Create New Sheet", style: .default, handler: { (alert:UIAlertAction!) -> Void in
                    FloatingController.show()
                    self.createSheet()
                }
            ))
            
            actionSheet.addAction(UIAlertAction(title: "Link Current Sheet", style: .default, handler: { (alert:UIAlertAction!) -> Void in
                FloatingController.show()
                DialogService.showDialog_ask("注意", "除非該表單為本帳冊的原始表單，否則第一次同步至其他現有表單會混合本機資料和線上資料，請確定目標表單無誤。"){
                    self.addSync()
                }
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Scan QR Code", style: .default, handler: { (alert:UIAlertAction!) -> Void in
                let QRHelper = QRScanViewController()
                QRHelper.finalHandler = {
                    self.navigationController!.popViewController(animated: false)
                    if(QRHelper.code != ""){
                        UIPasteboard.general.string = QRHelper.code
                        DialogService.showDialog_done("ID已複製到剪貼簿","")//FloatingController.show() will execute
                    }else{
                        FloatingController.show()
                    }
                }
                self.navigationController!.pushViewController(QRHelper, animated: false)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert:UIAlertAction!) -> Void in
            FloatingController.show()
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func decodeRawData(_ rows: [[String]]){
        let sheetIdx = AppDelegate.currentSheetIdx!
        var items = DM.table[sheetIdx].items
        
        for row in rows{
            guard let _ = Float(row[6]),
                let _ = Float(row[7]),
                let _ = Int(row[12]) else{
                    DialogService.showDialog_failed("格式有誤", "您可能曾手動修改表單內容但格式有誤。您可以手動修正錯誤，或是從重新建立新表單並同步。一般不建議手動修改表單。")
                    return
            }
            let amount = Float(row[6])! - Float(row[7])!
            let new_item = DS.Item(
                id: row[12],
                date: row[0],
                name: row[1],
                sort: row[2],
                state: row[4]=="Y",
                payer: row[3],
                reimburse: false,
                receipt: row[5]=="Y",
                amount: amount,
                note: row[10],
                path: "",
                timestamp: Int(row[13])!,
                delete: row[11]=="D"
            )
            
            var found = false
            for (i, item) in items.enumerated(){
                if new_item.id == item.id{
                    found = true
                    if(new_item.timestamp>item.timestamp){
                        items[i] = new_item
                    }
                    break
                }
            }
            if(!found){
                DM.table[sheetIdx].items.append(new_item)
            }
        }
        DM.table[sheetIdx].items = items
        DM.saveItems(sheetIdx: sheetIdx)
        //DialogService.showDialog_done("成功匯入", ""){}
        //self.showAlert(title: "成功匯入", message: "")
        self.importSucceed = true
    }
    
    func generateRawData()->[[String]]{
        var values:[[String]] = []
        values.append(["日期", "品名", "類別", "墊款人/負責人", "結清?", "單據?", "收入", "支出", "小記", "現金", "註記", "Delete?", "id", "timestamp"])
        for (idx, item) in DM.table[AppDelegate.currentSheetIdx!].items.enumerated(){
            let rowidx = idx+2
            var val_cal = "=G\(rowidx)-H\(rowidx)"
            var val_wal = "=IF(E\(rowidx)=\"Y\",G\(rowidx)-H\(rowidx),0)"
            if(idx>0){
                val_cal = "=I\(rowidx-1)+G\(rowidx)-H\(rowidx)"
                val_wal = "=IF(E\(rowidx)=\"Y\",I\(rowidx-1)+G\(rowidx)-H\(rowidx),I\(rowidx-1))"
            }
            if(item.delete){
                val_cal = idx>0 ? "=I\(rowidx-1)":"0"
                val_wal = idx>0 ? "=J\(rowidx-1)":"0"
            }
            if (item.amount > 0){
                values.append([item.date!, item.name!, item.sort!, item.payer!,
                               item.state ? "Y":"N", item.receipt ? "Y":"N", "\(item.amount)", "0",
                               val_cal, val_wal, item.note!,
                               item.delete ? "D" : "", "\(item.id)", "\(item.timestamp)"])
            }else{
                values.append([item.date!, item.name!, item.sort!, item.payer!,
                               item.state ? "Y":"N", item.receipt ? "Y":"N", "0", "\(-item.amount)",
                               val_cal, val_wal, item.note!,
                               item.delete ? "D" : "", "\(item.id)", "\(item.timestamp)"])
            }
        }
        return values
    }
    
    func generateQRCode(_ string: String)->CIImage{
        let data = string.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        let qrcodeImage = (filter?.outputImage)!
        
        let width = UIScreen.main.bounds.width / 1.1
        let scaleX = width / qrcodeImage.extent.size.width
        let scaleY = width / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        return transformedImage
    }
    
    func showQRCode(_ string: String) {
        let qrCIImage = generateQRCode(string)
        let qrImageView = UIImageView(frame: qrCIImage.extent )
        qrImageView.image = UIImage(ciImage: qrCIImage)
        //qrImageView.image?.withRenderingMode(.alwaysOriginal)
 
        let qrAlert = UIAlertController(
            title: "",
            message: nil,
            preferredStyle: .alert)
        
        qrAlert.view.addSubview(qrImageView)
        qrImageView.alignCenter(to: qrAlert.view)
        
        self.qrAlert = qrAlert
        
        FloatingController.showPartialButtons([false,false,false,true])
        _ = AppDelegate.floatingButtons[3]!.set(text: " "){
            if let qrAlert = self.qrAlert{
                qrAlert.dismiss(animated: true, completion: {
                    FloatingController.show()
                })
                self.qrAlert = nil
                _ = AppDelegate.floatingButtons[3]!.set(text: ""){}
            }
            
        }
        self.present(
            qrAlert,
            animated: true,
            completion: nil
        )
    }
    @objc func dismissQRAlert(){
        if let qrAlert = self.qrAlert{
            qrAlert.dismiss(animated: true, completion: {
                FloatingController.show()
            })
            self.qrAlert = nil
        }
    }
}
