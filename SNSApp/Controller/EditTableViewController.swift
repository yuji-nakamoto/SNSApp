//
//  EditTableViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/05.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class EditTableViewController: UITableViewController,UITextFieldDelegate {
    
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var selfIntroTextView: UITextView!
    @IBOutlet weak var alphaImage: UIView!
    @IBOutlet weak var changeHeaderImage: UIImageView!
    @IBOutlet weak var changeAvatarImage: UIImageView!
    
    var avatarImage: UIImage?
    var headerImage: UIImage?
    var datePicker: UIDatePicker = UIDatePicker()
    var pleaceholderLbl = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        navigationItem.title = "変更"
        usernameTextField.delegate = self
        emailTextField.delegate = self
        birthdayTextField.delegate = self
        usernameTextField.textColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1)
        setupAvatar()
        fetchUser()
        setupDatePicker()
        setupTextView()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupDatePicker() {
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale(identifier: "ja-JP")
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerAction))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        birthdayTextField.inputView = datePicker
        birthdayTextField.inputAccessoryView = toolbar
    }
    
    func setupTextView() {
        selfIntroTextView.delegate = self
        pleaceholderLbl.isHidden = false
        
        let pleaceholderX: CGFloat = self.view.frame.size.width / 75
        let pleaceholderY: CGFloat = -35
        let pleaceholderWidth: CGFloat = selfIntroTextView.bounds.width - pleaceholderX
        let pleaceholderHeight: CGFloat = selfIntroTextView.bounds.height
        let pleaceholderFontSize = self.view.frame.size.width / 25
        
        pleaceholderLbl.frame = CGRect(x: pleaceholderX, y: pleaceholderY, width: pleaceholderWidth, height: pleaceholderHeight)
        pleaceholderLbl.text = "プロフィールに自己紹介を追加する"
        pleaceholderLbl.font = UIFont(name: "HelveticaNeue", size: pleaceholderFontSize)
        pleaceholderLbl.textColor = .lightGray
        pleaceholderLbl.textAlignment = .left
        
        selfIntroTextView.addSubview(pleaceholderLbl)
    }
    
    @objc func datePickerAction() {
        birthdayTextField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        birthdayTextField.text = "\(formatter.string(from: datePicker.date))"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func setupAvatar() {
        profileImage.layer.cornerRadius = 35
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.borderWidth = 5
        alphaImage.layer.cornerRadius = 63/2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker_1))
        changeAvatarImage.addGestureRecognizer(tapGesture)
        let tapGestureForHeader = UITapGestureRecognizer(target: self, action: #selector(presentPicker_2))
        changeHeaderImage.addGestureRecognizer(tapGestureForHeader)
    }
    
    @objc func presentPicker_1() {
        view.endEditing(true)
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.present(picker, animated:  true, completion: nil)
    }
    
    @objc func presentPicker_2() {
        view.endEditing(true)
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated:  true, completion: nil)
    }
    
    
    func fetchUser() {
        UserApi().observeCurrentUser { (user) in
            self.usernameTextField.text = user.username
            self.accountTextField.text = user.account
            self.emailTextField.text = user.email
            self.birthdayTextField.text = user.birthday
            if let currentUser = Auth.auth().currentUser, let photoUrl = currentUser.photoURL {
                self.profileImage.sd_setImage(with: URL(string: photoUrl.absoluteString), completed: nil)
            }
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func saveBtnDidTapped(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show()
        var dict = Dictionary<String, Any>()
        if let username = usernameTextField.text, !username.isEmpty {
            dict["username"] = username
        }
        if let account = accountTextField.text, !account.isEmpty && account.hasPrefix("@") {
            dict["account"] = account
        }
        if let email = emailTextField.text, !email.isEmpty {
            dict["email"] = email
        }
        if let birthday = birthdayTextField.text, !birthday.isEmpty {
            dict["birthday"] = birthday
        }
        if let selfIntro = selfIntroTextView.text, !selfIntro.isEmpty {
            dict["selfIntro"] = selfIntro
        }
        
        
        UserApi().saveUserProfile(dict: dict, onSuccess: {
            if let img_1 = self.avatarImage {
                StorageApi().savePhotoProfile(image: img_1, uid: Auth.auth().currentUser!.uid, onSuccess: {
                
                }) { (errorMessage) in
                    ProgressHUD.showError(errorMessage)
                }
            } else {
                ProgressHUD.showSuccess()
            }
            
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
        UserApi().saveUserProfile(dict: dict, onSuccess: {
            if let img_2 = self.headerImage {
                StorageApi().savePhotoHeader(image: img_2, uid: Auth.auth().currentUser!.uid, onSuccess: {
                    ProgressHUD.showSuccess()
                }) { (errorMessage) in
                    ProgressHUD.showError(errorMessage)
                }
            } else {
                ProgressHUD.showSuccess()
            }
            
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
}

extension EditTableViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            headerImage = selectedImage
            headerImageView.image = selectedImage
            picker.dismiss(animated: true, completion: nil)
            return
        }
        if let selectedImage = info[.originalImage] as? UIImage {
            avatarImage = selectedImage
            profileImage.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension EditTableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let spacing = CharacterSet.whitespacesAndNewlines
        if !textView.text.trimmingCharacters(in: spacing).isEmpty {
            pleaceholderLbl.isHidden = true
        } else {
            pleaceholderLbl.isHidden = false
        }
        
    }
}
