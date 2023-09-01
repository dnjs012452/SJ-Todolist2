
import UIKit

final class AddViewController: UIViewController {
    private var initialHeightConstraint: NSLayoutConstraint?
    private var loadingView: UIView?
    private let existingText: String?
    var selectedSectionIndex: Int?
    var initialText: String?

    init(existingText: String? = nil) {
        self.existingText = existingText
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let contentView: UIStackView = {
        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.translatesAutoresizingMaskIntoConstraints = false

        return contentView
    }()

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "제목"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textColor = .label

        return titleLabel
    }()

    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "title"
        textField.font = UIFont.systemFont(ofSize: 19)
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 13.0
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always

        return textField
    }()

    let contentLabel: UILabel = {
        let contentLabel = UILabel()
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.text = "내용"
        contentLabel.font = UIFont.boldSystemFont(ofSize: 15)
        contentLabel.textColor = .label

        return contentLabel
    }()

    lazy var contentTextView: UITextView = {
        let contentTextView = UITextView()
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.text = "content"
        contentTextView.font = UIFont.systemFont(ofSize: 17)
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.cornerRadius = 15.0
        contentTextView.textContainerInset = UIEdgeInsets(top: 12, left: 5, bottom: 12, right: 5)
        contentTextView.textColor = .placeholderText

        contentTextView.delegate = self

        return contentTextView
    }()

    var delegate: AddTodoDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setUpViews()
        if let existingText = existingText {
            titleTextField.text = existingText
        }
        getSavedData()
        addNavButtons()
        setUpConstraints()
        sepupInitialHeightConstraint()

        titleTextField.delegate = self
        contentTextView.delegate = self
    }

    private func getSavedData() {
        if let savedTitle = UserDefaults.standard.string(forKey: "title") {
            titleTextField.text = savedTitle
        }

        if let savedContent = UserDefaults.standard.string(forKey: "content") {
            contentTextView.text = savedContent
        }
    }

    private func addNavButtons() {
        let rightButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTap))
        rightButton.tintColor = UIColor.label
        navigationItem.rightBarButtonItem = rightButton

        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 21),
            .foregroundColor: UIColor.label,
        ]
        navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        navigationItem.title = "Add Content"
    }

    // 화면에 보여지는 곳
    private func setUpViews() {
        view.addSubview(contentView)

        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, titleTextField])
        titleStackView.axis = .vertical
        titleStackView.spacing = 15
        contentView.addArrangedSubview(titleStackView)

        let contentStackView = UIStackView(arrangedSubviews: [contentLabel, contentTextView])
        contentStackView.axis = .vertical
        contentStackView.spacing = 15
        contentView.addArrangedSubview(contentStackView)
    }

    // done 버튼 눌렀을때
    @objc func doneButtonTap(_sender: Any) {
        guard let titleText = titleTextField.text,
              let contentText = contentTextView.text,
              let sectionIndex = selectedSectionIndex
        else { return }
        if titleText.isEmpty && contentText.isEmpty {
            return
        }
        showLoadingScreen()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.delegate?.didSaveNewTodo(todo: titleText + "\n" + contentText, section: sectionIndex)
            //

            //
            self.dismissLoadingScreen()
            //
            self.dismiss(animated: true)
        }
    }

    // 로딩화면
    private func showLoadingScreen() {
        // 로딩 화면 뷰 생성
        let loadingView = UIView(frame: view.bounds)
        loadingView.backgroundColor = .white
        loadingView.alpha = 0.5

        //
        let activityIndicator = UIActivityIndicatorView(style: .medium)

        activityIndicator.center = loadingView.center
        activityIndicator.startAnimating()

        // 뷰에 추가
        loadingView.addSubview(activityIndicator)
        view.addSubview(loadingView)

        self.loadingView = loadingView
    }

    // 로딩화면 사라짐
    private func dismissLoadingScreen() {
        guard let loadingView = loadingView else {
            return
        }

        loadingView.removeFromSuperview()

        self.loadingView = nil
    }

    private func sepupInitialHeightConstraint() {
        initialHeightConstraint = contentTextView.heightAnchor.constraint(equalToConstant: 150)
        initialHeightConstraint?.isActive = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // 레이아웃
    private func setUpConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // view
            contentView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            contentView.heightAnchor.constraint(equalTo: safeArea.heightAnchor),

            // 제목 라벨
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30.0),
            titleLabel.heightAnchor.constraint(equalToConstant: 20.0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 35.0),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30.0),

            // 제목 텍스트필드
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30.0),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30.0),
            titleTextField.heightAnchor.constraint(equalToConstant: 40.0),

            // 내용 라벨
            contentLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 30.0),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 35.0),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30.0),
            contentLabel.heightAnchor.constraint(equalToConstant: 20.0),

            // 내용 텍스트뷰
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30.0),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30.0),
            contentTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50.0),
            contentTextView.heightAnchor.constraint(equalToConstant: 150.0),
        ])
    }
}

extension AddViewController: UITextFieldDelegate {
    func textFieldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        contentTextView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        return true
    }
}

extension AddViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.isScrollEnabled {
            initialHeightConstraint?.constant = textView.contentSize.height
        }

        let maxHeight: CGFloat = 100

        if textView.contentSize.height >= maxHeight {
            textView.isScrollEnabled = true
            initialHeightConstraint?.constant = maxHeight
        } else {
            textView.isScrollEnabled = false
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        guard contentTextView.textColor == .placeholderText else { return }
        contentTextView.textColor = .label
        contentTextView.text = nil
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text.isEmpty {
            contentTextView.text = "introduce"
            contentTextView.textColor = .placeholderText
        }
    }
}

extension AddViewController {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
