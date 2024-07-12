import Extensions
import UIKit

class ColorPickerCell: UITableViewCell {
    
    let colorWell = UIColorWell()
    let colorLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let stack = UIStackView(arrangedSubviews: [colorLabel, colorWell])
        stack.alignment = .center
        contentView.addPinnedSubview(stack, height: 44)
        
        colorLabel.text = "#D6F1F0"
        
        colorWell.selectedColor = "#D6F1F0".uiColor
        colorWell.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
    }
    
    @objc
    func colorChanged(_ sender: UIColorWell) {
        colorLabel.text = sender.selectedColor?.hex
    }
    
    
    
}
