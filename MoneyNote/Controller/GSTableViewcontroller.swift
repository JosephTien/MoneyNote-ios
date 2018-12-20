import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

protocol MyGoogleServiceDelegate {
    func signInSucceed()
}
class GSTableViewcontroller: UITableViewController, GIDSignInDelegate, GIDSignInUIDelegate{
    //change framework if needed
    //************** Google Service **************
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    
    struct HandlerSet {
        var succeed: ((Any?)->()) = {_ in}
        var final: (()->()) = {}
        var error: (()->()) = {}
        init(){
            succeed = {_ in}
            final = {}
        }
        init(_ succeed: @escaping ((Any?)->()) ,_ final: @escaping (()->())){
            self.succeed = succeed
            self.final = final
        }
        init(_ succeed: @escaping ((Any?)->()), _ error: @escaping (()->()),_ final: @escaping (()->())){
            self.succeed = succeed
            self.final = final
            self.error = error
        }
    }
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets]
    private let service = GTLRSheetsService()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    var signInHandlerSet = HandlerSet()
    var createHandlerSet = HandlerSet()
    var updateHandlerSet = HandlerSet()
    var fetchHandlerSet = HandlerSet()
    
    override func viewDidLoad(){
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signOut()
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
            signInHandlerSet.error()
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            signInHandlerSet.succeed(nil)
        }
    }
    func signIn(succeedHandler: @escaping(Any?)->(), errorHandler: @escaping()->()){
        self.signInHandlerSet  = HandlerSet(succeedHandler, errorHandler, {})
        GIDSignIn.sharedInstance().signIn()
    }
    func createSheet(name: String, succeedHandler: @escaping (Any?)->(), finalHandler: @escaping ()->()) {
        self.createHandlerSet  = HandlerSet(succeedHandler, finalHandler)
        let newSheet = GTLRSheets_Spreadsheet.init()
        let properties = GTLRSheets_SpreadsheetProperties.init()
        properties.title = name
        newSheet.properties = properties
        let query = GTLRSheetsQuery_SpreadsheetsCreate.query(withObject:newSheet)
        /*query.fields = "spreadsheetId"
        query.completionBlock = { (ticket, result, NSError) in
            if let error = NSError {
                fatalError(error.localizedDescription)
            }else {
                let response = result as! GTLRSheets_Spreadsheet
                let identifier = response.spreadsheetId!
                completion(identifier)
            }
        }
        service.executeQuery(query, completionHandler: nil)
         */
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(createdWithTicket(ticket:finishedWithObject:error:))
        )
    }
    @objc func createdWithTicket(ticket: GTLRServiceTicket, finishedWithObject result:  GTLRSheets_Spreadsheet ,error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
        }else{
            createHandlerSet.succeed(result.spreadsheetId)
        }
        createHandlerSet.final()
    }
    func updateSheet(spreadsheetId: String, values: [[Any]], succeedHandler: @escaping (Any?)->(), finalHandler: @escaping ()->()){
        updateHandlerSet = HandlerSet(succeedHandler, finalHandler)
        let valueRange = GTLRSheets_ValueRange.init()
        valueRange.values = values
        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate
            .query(withObject: valueRange, spreadsheetId: spreadsheetId, range: "A1")
        query.valueInputOption = kGTLRSheetsValueInputOptionUserEntered
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(updateWithTicket(ticket:finishedWithObject:error:))
        )
    }
    @objc func updateWithTicket(ticket: GTLRServiceTicket, finishedWithObject result:  GTLRSheets_Spreadsheet ,error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
        }else{
            updateHandlerSet.succeed(nil)
        }
        updateHandlerSet.final()
    }
    func fetchSheet(spreadsheetId: String, succeedHandler: @escaping (Any?)->(), finalHandler: @escaping ()->()){
        let range = "A2:M"
        fetchHandlerSet = HandlerSet(succeedHandler, finalHandler)
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(fetchWithTicket(ticket:finishedWithObject:error:))
        )
    }
    @objc func fetchWithTicket(ticket: GTLRServiceTicket, finishedWithObject result: GTLRSheets_ValueRange ,error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
        }else if let values = result.values{
            fetchHandlerSet.succeed(values)
        }else{
            fetchHandlerSet.succeed([])
        }
        fetchHandlerSet.final()
    }
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    // **********************************
    // Followings are the Default Example
    // **********************************
    func setExampleView(){
        //GIDSignIn.sharedInstance().signInSilently()
        // Add the sign-in button.
        view.addSubview(signInButton)
        // Add a UITextView to display output.
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        view.addSubview(output);
    }
    
    // Display (in the UITextView) the names and majors of students in a sample
    // spreadsheet:
    // https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
    func listMajors() {
        output.text = "Getting sheet data..."
        let spreadsheetId = "1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms"
        let range = "Class Data!A2:E"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    // Process the response and display output
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result : GTLRSheets_ValueRange,
                                       error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var majorsString = ""
        let rows = result.values!
        
        if rows.isEmpty {
            output.text = "No data found."
            return
        }
        
        majorsString += "Name, Major:\n"
        for row in rows {
            let name = row[0]
            let major = row[4]
            
            majorsString += "\(name), \(major)\n"
        }
        
        output.text = majorsString
    }
}
