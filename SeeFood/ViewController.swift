
import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera //указываем тип imagePicker'a // Можно установить библиотеку фото, photoLibary
        imagePicker.allowsEditing = false // не разрешаем редактировать пользователю фото
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Действие после того как пользователь сфоткал
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            
            imageView.image = userPickedImage //исходное необрезанное изображение, выбранное пользователем.
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Faild to convert to ciimage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true)
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading coreML model faild")
        }//try? -> пробует, иначе nil
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Error to convert results")
            } // Объект, представляющий классификационную информацию, полученную в результате запроса на анализ изображения.
            if let firstResults = results.first{
                if firstResults.identifier.contains("hotdog"){
                    self.navigationItem.title = "Hotdog!"
                }else{
                    self.navigationItem.title = "Not hotdog! :C"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        }catch{
            print(error)
        }
    }
    
    
    
    @IBAction func CameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true)
    }
    
}

