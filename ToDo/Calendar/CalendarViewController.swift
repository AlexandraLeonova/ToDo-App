import SwiftUI
import UIKit

class CalendarViewController: UIViewController {
    
    let store: TodoStore

    lazy var dates = Array(store.todosByDeadline.keys).sorted { lhs, rhs in
        if lhs == nil {
            return false
        } else if rhs == nil {
            return true
        }
        guard let left = store.todosByDeadline[lhs]?[0].deadline else { return false }
        guard let right = store.todosByDeadline[rhs]?[0].deadline else { return true }

        return left < right
    }
    
    var isScrolling = false
    
    init(store: TodoStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    let addButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        view.backgroundColor = .backPrimary
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard dates.count != 0 else { return }
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CalendarCollectionViewCell.self))
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func setupUI() {
        setupTableView()
        setupCollectionView()
        setupButtons()
        
        view.addSubview(tableView)
        view.addSubview(collectionView)
        view.addSubview(addButton)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 100),
            
            tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        collectionView.backgroundColor = .backPrimary
        tableView.backgroundColor = .backPrimary
    }
    
    private func setupButtons() {
        let image = UIImage(systemName: "plus.circle.fill")?
            .applyingSymbolConfiguration(.init(paletteColors: [.white, .white, .tintColor]))?
            .applyingSymbolConfiguration(.init(pointSize: 44))
        addButton.setImage(image, for: .normal)
        addButton.tintColor = .colorBlue
        addButton.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        addButton.layer.shadowOpacity = 0.5
    }
    
    @objc func addTask() {
        let todoView = TodoView(todo: nil, onSave: {
            self.tableView.reloadData()
        }).environmentObject(store)
        
        present(UIHostingController(rootView: todoView), animated: true)
    }
}

extension CalendarViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return store.todosByDeadline.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.todosByDeadline[dates[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        
        let todo = todo(for: indexPath)
        
        if todo.isDone {
            cell.textLabel?.attributedText = todo.text.strikethrough
        } else {
            cell.textLabel?.attributedText = NSAttributedString(string: todo.text)
        }
        let color = todo.category.color.hex.uiColor
        let circleImage = UIImage(systemName: "circle.fill")?.withTintColor(color).withRenderingMode(.alwaysOriginal)
        let circle = UIImageView(image: circleImage)
        circle.layer.shadowColor = UIColor.black.cgColor
        circle.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        circle.layer.shadowOpacity = 0.3
        cell.accessoryView = circle
        return cell
    }
    

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if dates[section] == nil {
            return "Другое"
        }
        return dates[section]
    }
    
    func todo(for indexPath: IndexPath) -> TodoItem {
        let deadlineKey = dates[indexPath.section]
        let todos = store.todosByDeadline[deadlineKey] ?? []
        let todo = todos[indexPath.row]
        return todo
    }
    
    func changeIsDone(at indexPath: IndexPath) {
        store.save(todo(for: indexPath).switchIsDone())
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if todo(for: indexPath).isDone { return nil }
        
        let action = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completionHandler) in
            self?.changeIsDone(at: indexPath)
            completionHandler(true)
        }
        
        action.image = UIImage(systemName: "checkmark.circle.fill")
        action.backgroundColor = .colorGreen
    
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if !todo(for: indexPath).isDone { return nil }

        let action = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completionHandler) in
            self?.changeIsDone(at: indexPath)
            completionHandler(true)
        }
        
        action.image = UIImage(systemName: "x.circle")
        action.backgroundColor = .colorRed

        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension CalendarViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === tableView {
            if let topSectionIndex = tableView.indexPathsForVisibleRows?.map({ $0.section }).sorted().first,
               let selectedCollectionIndex = collectionView.indexPathsForSelectedItems?.first?.row,
               selectedCollectionIndex != topSectionIndex {
                let indexPath = IndexPath(item: topSectionIndex, section: 0)
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            isScrolling = false
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            isScrolling = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let todo = todo(for: indexPath)
        let todoView = TodoView(todo: todo) {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        } onDelete: {
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }.environmentObject(store)
        present(UIHostingController(rootView: todoView), animated: true)
    }
}

extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarCollectionViewCell.self), for: indexPath) as! CalendarCollectionViewCell
        cell.title = dates[indexPath.row]
        return cell
    }
    
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
}

extension CalendarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: indexPath.row), at: .top, animated: true)
        isScrolling = true
    }
}

extension String {
    var strikethrough: NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: 1,
            .strikethroughColor: UIColor.colorGray,
            .foregroundColor: UIColor.colorGray
        ]
        return NSAttributedString(string: self, attributes: attributes)
    }
}
