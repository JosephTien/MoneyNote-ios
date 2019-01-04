import UIKit

class SideConfigViewController: SideViewController{
    
    @IBOutlet weak var container: UIStackView!
    @IBOutlet weak var btn_io: UIButton!
    @IBOutlet weak var btn_sort: UIButton!
    @IBOutlet weak var btn_asc: UIButton!
    @IBOutlet weak var btn_deleted: UIButton!
    @IBOutlet weak var btn_filt: UIButton!
    
    enum SortMethod: Int{
        case none = 0
        case date = 1
        case name = 2
        case amount = 3
    }
    enum ShowType: Int{
        case all = 0
        case outcome = 1
        case income = 2

    }
    var state_deleted = false
    var state_sort: SortMethod = .none
    var state_asc = true
    var state_io: ShowType = .all
    var state_filt: [String] = []
    var handler_deleted: ((Bool)->())? = nil
    var handler_io: ((ShowType)->())? = nil
    var handler_sort: ((SortMethod)->())? = nil
    var handler_asc: ((Bool)->())? = nil
    var handler_filt: (()->())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set btn style
        btn_deleted.setBorder().setFloating()
        btn_deleted.setTitle(" 隱藏 ", for: .normal)
        btn_io.setBorder().setFloating()
        btn_io.setTitle(" 全部 ", for: .normal)
        btn_sort.setBorder().setFloating()
        btn_sort.setTitle(" 無 ", for: .normal)
        btn_asc.setBorder().setFloating()
        btn_asc.setTitle(" 順序 ", for: .normal)
        btn_asc.isHidden = true
        btn_filt.setBorder().setFloating()
        btn_filt.setTitle(" 0 filter ", for: .normal)
        //set btn action
        btn_deleted.addTarget(self, action: #selector(toggleDeleted), for: .touchUpInside)
        btn_io.addTarget(self, action: #selector(toggleIO), for: .touchUpInside)
        btn_sort.addTarget(self, action: #selector(toggleSort), for: .touchUpInside)
        btn_asc.addTarget(self, action: #selector(toggleAsc), for: .touchUpInside)
        btn_filt.addTarget(self, action: #selector(editFilter), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        windowColor = UIColor.white
        setBorderStyle()
    }
    
    func setBorderStyle(){
        let borderView = UIView(frame: view.frame)
        borderView.frame.origin = CGPoint(x: 0, y: 0)
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor.black.cgColor
        borderView.layer.cornerRadius = 15
        view.addSubview(borderView)
        borderView.isUserInteractionEnabled = false
    }
    
    
    @objc func toggleDeleted(){
        state_deleted = !state_deleted
        handler_deleted!(state_deleted)
        if(!state_deleted){
            btn_deleted.setTitle(" 隱藏 ", for: .normal)
        }else{
            btn_deleted.setTitle(" 顯示 ", for: .normal)
        }
    }
    @objc func toggleIO(){
        state_io = ShowType(rawValue: (state_io.rawValue + 1 ) % 3)!
        handler_io!(state_io)
        switch state_io{
        case .all:
            btn_io.setTitle(" 全部 ", for: .normal)
        case .outcome:
            btn_io.setTitle(" 支出 ", for: .normal)
        case .income:
            btn_io.setTitle(" 收入 ", for: .normal)
        }
        
    }
    @objc func toggleSort(){
        state_sort = SortMethod(rawValue: (state_sort.rawValue + 1 ) % 4)!
        handler_sort!(state_sort)
        btn_asc.isHidden = false
        switch state_sort{
        case .date:
            btn_sort.setTitle(" 日期 ", for: .normal)
        case .name:
            btn_sort.setTitle(" 名稱 ", for: .normal)
        case .amount:
            btn_sort.setTitle(" 金額 ", for: .normal)
        default:
            btn_sort.setTitle(" 無 ", for: .normal)
            btn_asc.isHidden = true
        }
    }
    @objc func toggleAsc(){
        state_asc = !state_asc
        handler_asc!(state_asc)
        if(!state_asc){
            btn_asc.setTitle(" 逆序 ", for: .normal)
        }else{
            btn_asc.setTitle(" 順序 ", for: .normal)
        }
    }
    
    @objc func editFilter(){
        handler_filt!()
        btn_filt.setTitle(" \(state_filt.count) filter ", for: .normal)
    }
    
}
