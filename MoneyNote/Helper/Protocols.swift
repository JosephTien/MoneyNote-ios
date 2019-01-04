protocol MyUiProtocol {
    func uiInit()
    func uiChange()
    func setFloatingButton()
    func enableFields(_ state: Bool)
    func clearFields()
    func validateField()->Bool
}

protocol MyDataProtocol {
    func addItem2List()
    func editItem2List(_ index: Int)
    func deleteItem2List(_ index: Int)
}
