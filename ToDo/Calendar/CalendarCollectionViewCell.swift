import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var title: String? {
        didSet {
            dateLabel.text = title ?? "Другое"
        }
    }
    
    private let dateLabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = .backPrimary
        contentView.addSubview(dateLabel)
        dateLabel.sizeToFit()
        dateLabel.center = contentView.center
        layer.cornerRadius = 16
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .backPrimarySelected : .backPrimary
            layer.borderColor = isSelected ? UIColor.colorGray.cgColor : UIColor.backPrimary.cgColor
            layer.borderWidth = isSelected ? 2 : 0
        }
    }
}
