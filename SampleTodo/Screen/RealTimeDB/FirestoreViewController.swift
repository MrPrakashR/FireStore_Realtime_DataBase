//
//  FirestoreViewController.swift
//  SampleTodo
//
//  Created by prautela on 01/08/24.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class FirestoreViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    var ref = DatabaseReference.init()
    var imagePicker : UIImagePickerController = UIImagePickerController()
    var chatList: [ChatModel] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(openGallery(tapGesture:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        getAllData()
    }
    
    @objc func openGallery(tapGesture: UITapGestureRecognizer) {
        setImagePicker()
    }

    private func saveData() {
        
        self.uploadImage(self.imageView.image!) { url in
            self.saveImage(name: self.textField.text ?? "", profileUrl: url!) { success in
                if (success != nil) {
                    debugPrint("Yeah.....")
                }
            }
        }
    }
    
    private func saveImage(name:String,profileUrl:URL,completion:@escaping (_ url:URL?)->()) {
        
        let data: [String : Any] = [
            "name":"Prakash",
            "text":textField.text ?? "",
            "profileImage":profileUrl.absoluteString
        ]
        self.ref.child("chat").childByAutoId().setValue(data)
    }
    
    @IBAction func saveData(_ sender: Any) {
        saveData()
    }
    
    func getAllData() {
        self.ref.child("chat").queryOrderedByKey().observe(.value) { (snapshot) in
            self.chatList.removeAll()
            if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapShot {
                    if let mainDict = snap.value as? [String:AnyObject] {
                        let name = mainDict["name"] as? String
                        let text = mainDict["text"] as? String
                        let profileImageUrl =   mainDict["profileImage"] as? String
                        self.chatList.append(ChatModel(name: name ?? "", text: text ?? "", profileImage: profileImageUrl ?? ""))
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension FirestoreViewController: UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    func setImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.isEditing = true
            
            self.present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = image
            self.dismiss(animated: true)
        }
    }
}

extension FirestoreViewController {
    
    func uploadImage(_ image:UIImage,completion:@escaping (_ url:URL?)->()) {
        
        let storageRef = Storage.storage().reference().child("myImage.png")
        let imageData = imageView.image?.pngData()
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        storageRef.putData(imageData!, metadata: metadata) { (metadata,error) in
            if error == nil {
                print("#Success")
                storageRef.downloadURL { (url, error) in
                    completion(url)
                }
            } else {
                debugPrint("error on uploading image")
                completion(nil)
            }
        }
        
    }
    
}

extension FirestoreViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.chatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        let model = self.chatList[indexPath.row]
        cell.nameLabel.text = model.name
        cell.value.text = model.text
        
        return cell
    }
    
}
