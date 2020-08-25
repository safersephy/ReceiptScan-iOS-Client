//
//  ViewController.swift
//  ReceiptApp
//
//  Created by Tijs van der Velden on 21/08/2020.
//  Copyright © 2020 SugarPush Creative Industries. All rights reserved.
//

import UIKit
import Alamofire


struct ResponseObject: Decodable {
    let ocr: String
    let image:String
}

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
    
class ViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    @IBOutlet var imageresult: UIImageView!
    @IBOutlet var OutputLabel2: UILabel!
    @IBOutlet var Outputview: UITextView!
    
    
    
    @IBAction func loadImageButtonTapped(_ sender: UIButton) {
    
    imagePicker.allowsEditing = false
    imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    
    }
    
    
 
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
         imagePicker.delegate = self
    }
    
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            let imageData:NSData = pickedImage.pngData()! as NSData

            
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            
        
            
            makeRequest(image: imageData as Data)
            
        }
     
        dismiss(animated: true, completion: nil)
    }
    



    struct RequestDTO: Codable {
    let image: String

  	// Conforming to Codable allows us to serialize this into JSON
    enum CodingKeys: String, CodingKey {
        case image = "image"
    }
}


    
    func makeRequest(image: Data) {
        let endpointUrl: String = "http://192.168.178.16:5002/upload"
       
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
       
       
       
        AF.upload(
            multipartFormData: { formData in
                formData.append(image, withName: "image", fileName: "image.jpg", mimeType: "image/jpg")
            },
        to: endpointUrl
        )
        .responseJSON { response in
        // Do something with the response
        // Or - create a struct called ResponseDTO, also conforming to Codable
        // And use `responseDecodable`
        
        let jsonData = " \(response.value ?? "error")".data(using: .utf8)!
        let responseobject: ResponseObject = try! JSONDecoder().decode(ResponseObject.self, from: jsonData)
        
        let ocrstring = responseobject.ocr
        
        
        let paddedstring = responseobject.image.padding(toLength: ((responseobject.image.count+3)/4)*4,
                  withPad: "=",
                  startingAt: 0)
      
        let newImageData = Data(base64Encoded: paddedstring)

        if let newImageData = newImageData {
              self.imageresult.image = UIImage(data: newImageData)
        }
        self.Outputview.text = responseobject.ocr
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        // then remove the spinner view controller
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
  }

}
}
