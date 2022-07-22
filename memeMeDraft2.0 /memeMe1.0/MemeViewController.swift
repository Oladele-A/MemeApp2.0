//
//  ViewController.swift
//  memeMe1.0
//
//  Created by macOS on 4/12/22.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: OUTLETS
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var imageViewBox: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!

    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var shareImageToolbar: UIToolbar!

    @IBOutlet weak var shareButtonLabel: UIBarButtonItem!
    
    // MARK: VARIABLES/CONSTANTS
    
    let bottomTextFieldDelegate = BottomTextFieldDelegate()
    
    // The default text attributes takes a dictionary. So we create a dictionary for it
    let appTextProperty : [NSAttributedString.Key:Any] = [
        NSAttributedString.Key.strokeColor : UIColor.black,
        NSAttributedString.Key.foregroundColor : UIColor.white,
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth : -3.5
    ]
    
    // MARK: LIFECYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        shareButtonLabel.isEnabled = false
        
        prepareTextField(textfield: topTextField, defaultText: "TOP")
        prepareTextField(textfield: bottomTextField, defaultText: "BOTTOM")
        
        // Assign appropriate delegates to each text field
        self.topTextField.delegate = self
        self.bottomTextField.delegate = bottomTextFieldDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: PRIVATE METHODS
    
    // Function to set the default properties of the text field once the view is loaded into memory.
    func prepareTextField(textfield:UITextField, defaultText:String){
        textfield.text = defaultText
        textfield.defaultTextAttributes = appTextProperty
        textfield.textAlignment = .center
    }
    
    func pickImage(sourceType:UIImagePickerController.SourceType){
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        present(controller, animated: true, completion: nil)
    }
    
    /*
     The following lines of code will walk us through how to prevent the keyboard from covering the bottom text field. Basically, we want the view to slide up when keyboard appears on the screen after the user click the bottom text field. The view should also slide back down when the user is done editting
     */
    
    // First we get the height of the incoming keyboard with NSNOtification
    func getKeyboardHeight(_ notification : Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardHeight = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardHeight.cgRectValue.height
    }
    
    // Second, we subtract the height of the keyboard from the views frame.
    // y equals 0 at the top of the screen
    @objc func keyboardWillShow(_ notification:Notification){
        if bottomTextField.isFirstResponder && view.frame.origin.y == 0{
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    //Third step is to subscribe to the keyboard notifications. Handles the notifications for showing and hiding the keyboard.
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Fourth, Call the the subscribe to keyboard notification method in viewWillAppear
    
    // Fifth, Unsubscribe from the keyboard notification. Handles the notification showing and hiding the keyboard
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Sixth, call the unsubscribe from keyboard notifications in viewWillDisappear
    
    // Next write a function  to make the view slide back downn.
    @objc func keyboardWillHide(_ notification:Notification){
        if view.frame.origin.y != 0{
            view.frame.origin.y = 0
        }
    }
    
    // Finally,Subscribe and unsubscribe to the keyboardWillHideNotifications.Add the lines to subscribe in our already existing keyboard notifications in step 3 & 5
    
    // Function to generate screenshot of the meme editor
    func generateMemedImage() -> UIImage {
        //Hide the toolbar and navigation bar in before creating memed image
        self.toolBar.isHidden = true
        self.shareImageToolbar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.toolBar.isHidden = false
        self.shareImageToolbar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false

        return memedImage
    }
    
    // Function to instantiate the Model
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageViewBox.image!, memedImage: generateMemedImage())
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
  
    
    // MARK: DELEGATE METHODS
    
    /*
     These are the delagete methods for the UIImagePickerController Here, we define what the image picker controller can do.
     */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageViewBox.image = image
        }
        shareButtonLabel.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
     The following lines of code will be the  delagate methods for the UITextField. Here we set the behavior of the text field assigned to this delegae.
     */
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.text == "TOP"{
            textField.text = ""
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text! as NSString
        newText.replacingCharacters(in: range, with: string)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == ""{
            textField.text = "TOP"
        }
        return true
    }
    
    // MARK: IBActions and Extenstions
    
    /*
     IB Actions that enable us  to connect buttons to code
     */
    
    // picking an image from library and camera will have same code and the only difference is the sourceType. Instead of repeating the same code twice, we can create a method that takes the source type as a parameter and then go ahead to present the imagePickerControlller with the specified source type. Check the private functions mark for this method
    
    @IBAction func pickAnImageFromLibrary(_ sender: Any) {
        pickImage(sourceType: .photoLibrary)
    }
    
    @IBAction func pickAnImageFeomCamera(_ sender: Any) {
        pickImage(sourceType: .camera)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        let memedImage: UIImage = generateMemedImage()
        let shareController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        shareController.completionWithItemsHandler = {(activityType:UIActivity.ActivityType?, completed:Bool, arrayReturnedItems:[Any]?, error:Error?) in
            if completed{
//                print("copy completed")
                self.save()
                self.dismiss(animated: true, completion: nil)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(shareController, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelMemeEditor(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
