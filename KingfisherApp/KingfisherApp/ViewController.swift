import UIKit
import SparkUI
import Layoutless
import ReactiveKit
import Bond
import Kingfisher

class ViewController: SViewController {

    let url = "https://unsplash.com/photos/JO_S6ewBqAk/download?ixid=MnwxMjA3fDB8MXxzZWFyY2h8NHx8bWFjYm9vayUyMHByb3xlbnwwfHx8fDE2NzcxMTE0NzE&force=true&w=640"
    let imageView = UIImageView()
        .background(color: .systemGray3)
        .masksToBounds()
        .contentMode(.scaleAspectFit)
    
    let fetchButton = UIButton()
        .text("Fetch image")
        .text(color: .systemBlue)
        .bold()
    
    let grabButton = UIButton()
        .text("Grab image")
        .text(color: .systemBlue)
        .bold()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func layoutViews() {
        super.layoutViews()
        stack(.vertical, spacing: 15)(
            imageView.sizing(toHeight: 200),
            fetchButton,
            grabButton,
            Spacer()
        ).fillingParent().layout(in: container)
    }
    
    override func subscribe() {
        super.subscribe()
        fetchButton.reactive.tap.observeNext {
            guard let downloadURL = URL(string: self.url) else { return }
            let resource = ImageResource(downloadURL: downloadURL, cacheKey: "macbook")
            let processor = RoundCornerImageProcessor(cornerRadius: 80)
            let placeholder = UIImage(named: "tianyi")
            self.imageView.kf.indicatorType = .activity
            self.imageView.kf.setImage(with: resource,
                                       placeholder: placeholder,
                                       options: [.processor(processor)],
            progressBlock: { receivedSize, totalSize in
                print(receivedSize, totalSize)
            }) { result in
                self.hande(result)
            }
        }.dispose(in: bag)
        
        grabButton.reactive.tap.observeNext {
            guard let downloadURL = URL(string: self.url) else { return }
            let resource = ImageResource(downloadURL: downloadURL, cacheKey: "macbook")
            KingfisherManager.shared.retrieveImage(with: resource) { result in
                self.hande(result)
            }
        }.dispose(in: bag)
    }
    
    func hande(_ result: Result<RetrieveImageResult, KingfisherError>) {
        switch result {
        case .success(let retreiveImageResult):
            let image = retreiveImageResult.image
            let cacheType = retreiveImageResult.cacheType
            let source = retreiveImageResult.source
            let originalSource = retreiveImageResult.originalSource
            let message = """
            Image size:
            \(image.size)
            
            Cashe:
            \(cacheType)
            
            Source:
            \(source)
            
            Original Source:
            \(originalSource)
            """
            SAlertController.showSuccess(message: message)
        case .failure(let error):
            SAlertController.showError(message: error.localizedDescription)
        }
    }
}

