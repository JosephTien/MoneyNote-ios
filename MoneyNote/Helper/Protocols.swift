import UIKit

extension UIStoryboard {
    enum Storyboard: String {
        case Main
    }
    
    convenience init(_ storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    class func storyboard(storyboard: Storyboard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.rawValue, bundle: bundle)
    }
}
protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}
extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}
extension UIViewController : StoryboardIdentifiable { }
extension UIStoryboard {
    func instantiateViewController<T: UIViewController>() -> T{
        let optionalViewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier)
        guard let viewController = optionalViewController as? T else {
            fatalError("Couldn’t instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        return viewController
    }
    func instantiateViewController<T: UIViewController>(type: T.Type) -> T? {
        let id = String(describing: T.self)
        return instantiateViewController(withIdentifier: id) as? T
    }
}
//--------------------------------------------------
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
