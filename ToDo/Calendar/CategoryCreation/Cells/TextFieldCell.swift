import Extensions
import UIKit

class TextFieldCell: UITableViewCell {
    
    init(placeholder: String? = nil) {
        super.init(style: .default, reuseIdentifier: nil)
        setup()
        textField.placeholder = placeholder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    let textField = UITextField()
        
    private func setup() {
        contentView.addPinnedSubview(textField, height: 44)
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
    }
}

