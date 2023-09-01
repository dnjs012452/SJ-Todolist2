
import UIKit

class ViewController: UIViewController {
    let imageView = UIImageView()
    let stackView = UIStackView()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Todo"
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 30)]
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        
        setupButtons()
        setupImageView()
        fetchCatImage()
    }
    
    private func setupButtons() {
        let todoGoButton = UIButton(type: .system)
        todoGoButton.setTitle("할일 확인하기", for: .normal)
       
        todoGoButton.tintColor = .black
        todoGoButton.titleLabel?.font = UIFont(name: "Helvetica", size: 17)
        todoGoButton.addTarget(self, action: #selector(todoGoButtonTapped), for: .touchUpInside)
        
        let doneGoButton = UIButton(type: .system)
        doneGoButton.setTitle("완료된일 보기", for: .normal)
        doneGoButton.addTarget(self, action: #selector(doneGoButtonTapped), for: .touchUpInside)
        doneGoButton.tintColor = .black
        doneGoButton.titleLabel?.font = UIFont(name: "Helvetica", size: 17)
        stackView.addArrangedSubview(todoGoButton)
        stackView.addArrangedSubview(doneGoButton)
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
        ])
    }
    
    @objc private func todoGoButtonTapped() {
        
        let todoViewController = TodoViewController()
        navigationController?.pushViewController(todoViewController, animated: true)
    }
    
    @objc private func doneGoButtonTapped() {
        
        let doneViewController = DoneViewController()
        navigationController?.pushViewController(doneViewController, animated: true)
    }
    
    private func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // 이미지 탭
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTapGesture)
        
        // image touch 라벨
        let label = UILabel()
        label.text = "Image Touch!"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -15),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 260),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -70)
        ])
    }
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        fetchCatImage()
    }

    private func fetchCatImage() {
        let urlAddress = "https://api.thecatapi.com/v1/images/search"
        guard let url = URL(string: urlAddress) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if error != nil {
                print("Failed fetching image:", error!)
                return
            }
            guard let data = data else { return }
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                    if let imgUrlString = jsonArray[0]["url"] as? String,
                       let imgUrl = URL(string: imgUrlString)
                    {
                        DispatchQueue.main.async {
                            self?.imageView.load(url: imgUrl)
                        }
                    }
                } else {
                    print("bad json")
                }
            } catch let error as NSError {
                print(error)
            }
        }.resume()
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}
