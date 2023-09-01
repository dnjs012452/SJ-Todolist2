import UIKit

final class DoneViewController: UIViewController, UITableViewDataSource {
    let doneTableView = UITableView()
    var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(doneTableView)
        doneTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneTableView.topAnchor.constraint(equalTo: view.topAnchor),
            doneTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            doneTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            doneTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        doneTableView.dataSource = self
        doneTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let data = UserDefaults.standard.data(forKey: "items"),
           let savedItems = try? JSONDecoder().decode([[Task]].self, from: data)
        {
            tasks = savedItems.flatMap { $0 }.filter { $0.done }
            doneTableView.reloadData()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = tasks[indexPath.row].title
        
        return cell
    }
}
