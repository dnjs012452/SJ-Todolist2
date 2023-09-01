import UIKit

final class TodoViewController: UIViewController, AddTodoDelegate {
    // 테이블뷰와 섹션 이름, 할 일 항목들을 저장할 변수들 - 인스턴스, 프로퍼티
    let addTableView = UITableView()
    var sections = ["월요일", "화요일"]
    var items: [[Task]] = [[], []]
    var doneItems: [Task] = []

    // 현재 선택된 섹션의 인덱스를 저장할 변수 - 프로퍼티
    var selectedSectionIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6

        // UserDefaults에서 전체 할 일 목록을 불러옴
        if let data = UserDefaults.standard.data(forKey: "items"),
           let savedItems = try? JSONDecoder().decode([[Task]].self, from: data)
        {
            items = savedItems
        }

        if let data = UserDefaults.standard.data(forKey: "sections"),
           let savedSections = try? JSONDecoder().decode([String].self, from: data)
        {
            sections = savedSections
        } else {
            sections = ["월요일", "화요일"]
            if let data = try? JSONEncoder().encode(sections) {
                UserDefaults.standard.set(data, forKey: "sections")
            }
        }

        setupTableView()
        setupNavigationBar()
        addButton()
        selectedSectionIndex = 0
    }

    // 새로운 할 일 아이템 추가하는 화면으로 이동
    @objc func addTodo() {
        let vc = AddViewController()
        vc.selectedSectionIndex = selectedSectionIndex
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
    }

    private func setupTableView() {
        view.addSubview(addTableView)

        addTableView.translatesAutoresizingMaskIntoConstraints = false
        addTableView.register(TodoTableViewCell.self, forCellReuseIdentifier: "TodoCell")
        addTableView.backgroundColor = .systemGray6
        setTableViewConstraints()

        addTableView.dataSource = self
        addTableView.delegate = self
    }

    private func addButton() {
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = UIColor.systemBlue
        addButton.layer.cornerRadius = 25
        addButton.addTarget(self, action: #selector(addTodo), for: .touchUpInside)

        view.addSubview(addButton)

        addButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -35),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
        ])
    }

    private func setTableViewConstraints() {
        let padding: CGFloat = 15 // 원하는 패딩 값으로 변경

        NSLayoutConstraint.activate([
            addTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            addTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            addTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func setupNavigationBar() {
        // edit 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))

        // 섹션 선택 버튼
        let selectSectionButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(selectSection))

        navigationItem.rightBarButtonItems = [selectSectionButton, navigationItem.rightBarButtonItem].compactMap { $0 }
    }

    // edit 버튼 눌렀을때
    @objc func editTapped() {
        if addTableView.isEditing {
            addTableView.setEditing(false, animated: true)
            navigationItem.leftBarButtonItem?.title = "Edit"
        } else {
            addTableView.setEditing(true, animated: true)
            navigationItem.leftBarButtonItem?.title = "Done"
        }
    }

    // 사용자가 새로운 할 일을 추가했을 때 호출되는 메소드
    func didSaveNewTodo(todo: String, section: Int) {
        // 새로운 Task를 생성하고 해당 섹션의 배열에 추가
        let task = Task(title: todo)
        items[section].append(task)

        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: "items")
        }

        reloadDataOnMainThread()
    }

    private func reloadDataOnMainThread() {
        DispatchQueue.main.async { [weak self] in
            self?.addTableView.reloadData()
        }
    }

    @objc func didSelectCell(at indexPath: IndexPath) {
        let item = items[indexPath.section][indexPath.row]
        let vc = AddViewController()
        vc.selectedSectionIndex = selectedSectionIndex
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
    }

    // 섹션 버튼(알럿창)
    @objc func selectSection() {
        let alertController = UIAlertController(title: "Select Section", message: nil, preferredStyle: .alert)

        for (index, section) in sections.enumerated() {
            alertController.addAction(UIAlertAction(title: section, style: .default) { _ in

                self.selectedSectionIndex = index
            })
            // delete action
            alertController.addAction(UIAlertAction(title: "Delete \(section)", style: .destructive) { _ in
                self.items.remove(at: index)
                self.sections.remove(at: index)

                // 전체 섹션 목록과 아이템들을 UserDefaults에 저장합니다.
                if let data = try? JSONEncoder().encode(self.sections) {
                    UserDefaults.standard.set(data, forKey: "sections")
                }
                if let data = try? JSONEncoder().encode(self.items) {
                    UserDefaults.standard.set(data, forKey: "items")
                }
                self.addTableView.reloadData()
            })
        }

        alertController.addAction(UIAlertAction(title: "Add Section", style: .default) { _ in
            let addSectionAlertController = UIAlertController(title: "New Section", message: "Enter a name for this section.", preferredStyle: .alert)

            addSectionAlertController.addTextField()

            let addAction = UIAlertAction(title: "Add", style: .default) { [unowned addSectionAlertController] _ in
                if let newSectionName = addSectionAlertController.textFields?[0].text {
                    self.sections.append(newSectionName)
                    self.items.append([])
                    // 전체 섹션 목록을 UserDefaults에 저장
                    if let data = try? JSONEncoder().encode(self.sections) {
                        UserDefaults.standard.set(data, forKey: "sections")
                    }
                    self.addTableView.reloadData()
                }
            }

            addSectionAlertController.addAction(addAction)

            self.present(addSectionAlertController, animated: true)
        })

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)
    }
}

// 셀 관련
class TodoTableViewCell: UITableViewCell {
    let cellPadding: CGFloat = 5
    let cornerRadius: CGFloat = 10

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        // backgroundView 생성 및 설정
        let backgroundCellView = UIView()
        backgroundCellView.backgroundColor = .white
        backgroundCellView.layer.cornerRadius = cornerRadius
        self.backgroundView = backgroundCellView

        contentView.clipsToBounds = true
    }

    // NSCoder를 사용하여 초기화하는 것을 금지함
    // 이 클래스의 인스턴스는 오직 코드를 통해서만 생성되어야 함
    // 만약 인터페이스 빌더에서 이 클래스의 객체를 생성하려고 시도하면 앱이 크래시됨
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        textLabel?.text = text
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: cellPadding, bottom: 0, right: cellPadding))
    }
}

// UITableViewDataSource 프로토콜은 테이블뷰 데이터 소스를 관리하기 위한 메소드들의 집합
extension TodoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }

    // 셀 관련 코드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoTableViewCell
        let task = items[indexPath.section][indexPath.row]
        cell.configure(with: task.title)
        cell.backgroundColor = .clear
        if task.done {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .systemGray2
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

// UITableViewDelegate 프로토콜은 테이블뷰의 동작과 외관에 대한 메소드들의 집합
extension TodoViewController: UITableViewDelegate {
    //
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear

        let label = UILabel()
        label.text = sections[section]
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.frame = CGRect(x: 15, y: 5, width: tableView.bounds.size.width - 30, height: 25)

        headerView.addSubview(label)

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .white

        return footerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }

    // 셀 터치시 작성된 뷰 표시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = items[indexPath.section][indexPath.row]
//        let vc = AddViewController()
//        vc.selectedSectionIndex = selectedSectionIndex
//        vc.delegate = self
//
//        vc.initialText = item.title
//        let navController = UINavigationController(rootViewController: vc)
//        present(navController, animated: true)
        // 셀 터치시 체크마크 표시
        items[indexPath.section][indexPath.row].done.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        let task = items[indexPath.section][indexPath.row]

        if task.done {
            doneItems.append(task)
        } else {
            if let index = doneItems.firstIndex(where: { $0.title == task.title }) {
                doneItems.remove(at: index)
            }
        }
        // 전체 할 일 목록을 UserDefaults에 저장
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: "items")
        }
    }

    // 스와이프 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            if items[indexPath.section].isEmpty {
                editTapped()
            }

            // 전체 할 일 목록을 UserDefaults에 저장
            if let data = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(data, forKey: "items")
            }
        }
    }

    // 셀 정렬
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let task = items[sourceIndexPath.section][sourceIndexPath.row]
        items[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        items[destinationIndexPath.section].insert(task, at: destinationIndexPath.row)
    }
}

// AddTodoDelegate 프로토콜은 새로운 할 일 아이템이 추가됐음을 알려주기 위한 메소드를 정의
protocol AddTodoDelegate {
    func didSaveNewTodo(todo: String, section: Int)
}

class Task: Codable {
    var title: String
    var done: Bool

    init(title: String, done: Bool = false) {
        self.title = title
        self.done = done
    }
}
