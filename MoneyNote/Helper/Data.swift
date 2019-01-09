import Foundation
//----------------------------------------------------------------------
class DS{//DataStructure
    struct Item: Codable{
        var id: String = ""
        var date: String? = ""
        var name: String? = ""
        var sort: String? = ""
        var state: Bool = false
        var payer: String? = ""
        var reimburse: Bool = false
        var receipt: Bool = false
        var amount: Float = 0.0
        var path: String = ""
        var timestamp: Int = 0
        var delete: Bool = false
        static let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                 in: .userDomainMask).first!
        static let propertyEncoder = PropertyListEncoder()
        static func createForder(){
            do
            {
                let dirpath = DS.Item.documentsDirectory.appendingPathComponent("Sheets/")
                try FileManager.default.createDirectory(atPath: dirpath.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError
            {
                NSLog("Skip Creation: \(error.debugDescription)")
            }
        }
        
        static func saveToFile(items: [Item], name: String) {
            createForder()
            let propertyEncoder = PropertyListEncoder()
            if let data = try? propertyEncoder.encode(items) {
                let url = Item.documentsDirectory.appendingPathComponent("Sheets/" + name)
                try? data.write(to: url)
            }
            print(documentsDirectory)
        }
        static func readItemsFromFile(_ name: String) -> [Item]? {
            let propertyDecoder = PropertyListDecoder()
            let url = Item.documentsDirectory.appendingPathComponent("Sheets/" + name)
            if let data = try? Data(contentsOf: url), let items = try?
                propertyDecoder.decode([Item].self, from: data) {
                return items
            } else {
                return nil
            }
        }
        func deleteImageFile(){
            if path == ""{return}
            do {
                let fileManager = FileManager.default
                try fileManager.removeItem(atPath: path)
            }
            catch let error as NSError {
                print("FileManager error: \(error)")
            }
        }
    }
//----------------------------------------------------------------------
    struct Sheet: Codable{
        var id: Int = 0
        var name: String = ""
        var spreadSheet: String = ""
        var lastSyncTime = ""
        
        static let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                 in: .userDomainMask).first!
        static let propertyEncoder = PropertyListEncoder()
        static func saveToFile(sheets: [Sheet]) {
            let propertyEncoder = PropertyListEncoder()
            if let data = try? propertyEncoder.encode(sheets) {
                let url = Item.documentsDirectory.appendingPathComponent("SheetList")
                try? data.write(to: url)
            }
            print(documentsDirectory)
        }
        static func readSheetsFromFile() -> [Sheet]? {
            print(Item.documentsDirectory)
            let propertyDecoder = PropertyListDecoder()
            let url = Item.documentsDirectory.appendingPathComponent("SheetList")
            if let data = try? Data(contentsOf: url), let items = try?
                propertyDecoder.decode([Sheet].self, from: data) {
                return items
            } else {
                return nil
            }
        }
        
        static func deleteFile(_ item: Item){
            if item.path == ""{return}
            do {
                let fileManager = FileManager.default
                try fileManager.removeItem(atPath: item.path)
            }
            catch let error as NSError {
                print("FileManager error: \(error)")
            }
        }
    }
    //----------------------------------------------------------------------
    struct TableComponent{
        var sheet: Sheet
        var items: [Item]
        func calculate()->(Float, Float){
            var count: Float = 0
            var cash: Float = 0
            for item in items{
                if(!item.delete){
                    count += item.amount
                    if item.state{
                        cash += item.amount
                    }
                }
            }
            return (count, cash)
        }
        func statue()->(Int, Int){
            var notPaid = 0
            var noReceipt = 0
            for item in items{
                if(!item.delete){
                    if(!item.state){
                        notPaid = notPaid + 1
                    }
                    if(!item.receipt){
                        noReceipt = noReceipt + 1
                    }
                }
            }
            return (notPaid, noReceipt)
        }
    }
    struct UsualList: Codable{
        var strings:[String] = []
        var sorts:[String] = []
        var users:[String] = []
        static let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                 in: .userDomainMask).first!
        static let propertyEncoder = PropertyListEncoder()
        func saveToFile() {
            let propertyEncoder = PropertyListEncoder()
            if let data = try? propertyEncoder.encode(self) {
                let url = Item.documentsDirectory.appendingPathComponent("UsualList")
                try? data.write(to: url)
            }
            print(DS.UsualList.documentsDirectory)
        }
        static func readListFromFile() -> UsualList? {
            print(Item.documentsDirectory)
            let propertyDecoder = PropertyListDecoder()
            let url = Item.documentsDirectory.appendingPathComponent("UsualList")
            if let data = try? Data(contentsOf: url), let usualList = try?
                propertyDecoder.decode(UsualList.self, from: data) {
                return usualList
            } else {
                return nil
            }
        }
    }
}
class DM{
    static var table: [DS.TableComponent] = []
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                             in: .userDomainMask).first!
    static var usualList = DS.UsualList()
    static func loadUsualList(){
        if let usualList = DS.UsualList.readListFromFile() {
              DM.usualList = usualList
        }
    }
    static func loadTable(){
        if let sheets = DS.Sheet.readSheetsFromFile() {
            table.reserveCapacity(sheets.count)
            for sheet in sheets{
                table.append(
                    DS.TableComponent(
                        sheet: sheet,
                        items: DS.Item.readItemsFromFile(String(sheet.id)) ?? []
                    )
                )
            }
        }
    }
    static func addSort(_ sort: String){
        usualList.sorts = [sort] + usualList.sorts
        usualList.saveToFile()
    }
    static func deleteSort(_ idx: Int){
        usualList.sorts.remove(at: idx)
        usualList.saveToFile()
    }
    static func addUser(_ user: String){
        usualList.users = [user] + usualList.users
        usualList.saveToFile()
    }
    static func deleteUser(_ idx: Int){
        usualList.users.remove(at: idx)
        usualList.saveToFile()
    }
    static func deleteItem(sheetIdx: Int, itemIdx: Int){
        //soft delete
        table[sheetIdx].items[itemIdx].delete = true
        table[sheetIdx].items[itemIdx].timestamp = Date().secondFrom1970()
        //hard delete
        /*
        DS.Item.deleteFile(table[sheetIdx].items[itemIdx])
        table[sheetIdx].items.remove(at: itemIdx)
        */
        saveItems(sheetIdx: sheetIdx)
    }
    static func recoverItem(sheetIdx: Int, itemIdx: Int){
        table[sheetIdx].items[itemIdx].delete = false
        table[sheetIdx].items[itemIdx].timestamp = Date().secondFrom1970()
        saveItems(sheetIdx: sheetIdx)
    }
    static func addItem(sheetIdx: Int, item: DS.Item){
        var item_new = item
        item_new.timestamp = Date().secondFrom1970()
        table[sheetIdx].items = [item_new] + table[sheetIdx].items
        saveItems(sheetIdx: sheetIdx)
    }
    static func editItem(sheetIdx: Int, itemIdx: Int, item: DS.Item){
        table[sheetIdx].items[itemIdx].deleteImageFile()
        var item_new = item
        item_new.timestamp = Date().secondFrom1970()
        table[sheetIdx].items[itemIdx] = item_new
        saveItems(sheetIdx: sheetIdx)
    }
    static func saveItems(sheetIdx: Int){
        let fileName = String(table[sheetIdx].sheet.id)
        DS.Item.saveToFile(items: table[sheetIdx].items, name: fileName)
    }
    
    static func getSheets()->[DS.Sheet]{
        var sheets: [DS.Sheet] = []
        sheets.reserveCapacity(table.count)
        for tc in table{
            sheets.append(tc.sheet)
        }
        return sheets
    }
    static func addSheet(sheet: DS.Sheet){
        table = [DS.TableComponent(sheet: sheet, items: [])] + table
        saveSheets()
    }
    static func deleteSheet(sheetIdx: Int){
        for item in table[sheetIdx].items{
            item.deleteImageFile()
        }
        deleteFile("Sheets/"+String(table[sheetIdx].sheet.id))
        table.remove(at: sheetIdx)
        saveSheets()
    }
    static func saveSheets(){
        DS.Sheet.saveToFile(sheets: getSheets())
    }
    static func deleteFile(_ relativePath: String){
        do {
            let filepath = documentsDirectory.appendingPathComponent(relativePath).path
            let fileManager = FileManager.default
            try fileManager.removeItem(atPath: filepath)
        }
        catch let error as NSError {
            print("FileManager error: \(error)")
        }
    }
    static func getCurrentSheet()->DS.Sheet?{
        if(AppDelegate.currentSheetIdx!>=0){
            return table[AppDelegate.currentSheetIdx!].sheet
        }
        return nil
    }
    static func getCurrentItem()->DS.Item?{
        if(AppDelegate.currentSheetIdx!>=0 && AppDelegate.currentItemIdx!>=0){
            return table[AppDelegate.currentSheetIdx!].items[AppDelegate.currentItemIdx!]
        }
        return nil
    }
}
