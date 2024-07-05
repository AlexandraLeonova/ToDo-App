import UIKit

class CategoryCreationTableViewController: UITableViewController {

    let store: TodoStore
    let titleCell = TextFieldCell(placeholder: "Моя категория")
    let colorCell = ColorPickerCell()
    let savingCell = UITableViewCell()

    
    init(store: TodoStore) {
        self.store = store
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .backPrimary
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            titleCell.selectionStyle = .none
            titleCell.textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
            return titleCell
            
        } else if indexPath.section == 1 {
            colorCell.selectionStyle = .none
            return colorCell
            
        } else {
            var content = savingCell.defaultContentConfiguration()
            content.text = "Создать"
            content.textProperties.alignment = .center
            content.textProperties.color = .colorGray
            savingCell.selectionStyle = .none
            savingCell.contentConfiguration = content
            return savingCell
            
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Категория"
        } else if section == 1 {
            return "Цвет"
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 2 else { return }
        let category = TodoItem.Category(
            name: titleCell.textField.text ?? "",
            color: TodoItem.Color(
                hex: colorCell.colorLabel.text ?? "",
                opacity: 1.0
            )
        )
        store.save(category)
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func textChanged(_ sender: UITextField) {
        var content = savingCell.contentConfiguration as? UIListContentConfiguration
        if sender.text == "" {
            content?.textProperties.color = .colorGray
            savingCell.selectionStyle = .none
        } else {
            content?.textProperties.color = .colorBlue
            savingCell.selectionStyle = .default
        }
        savingCell.contentConfiguration = content
    }
    
}
