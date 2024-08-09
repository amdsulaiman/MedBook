//
//  LoginVC.swift
//  MedBook
//
//  Created by Mohammed Sulaiman on 08/08/24.
//

import UIKit
import TweeTextField

class LoginVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var emailText: TweeAttributedTextField!
    @IBOutlet weak var passwordText: TweeAttributedTextField!
    @IBOutlet weak var loginBgView: UIView!
    @IBOutlet weak var loginBtnRef: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Methods
    private func setupUI() {
        titleLabel.textColor = UIColor.black
        subTitleLabel.textColor = UIColor.systemGray2
        titleLabel.font = .metropolisBold(size: 18)
        subTitleLabel.font = .metropolisBold(size: 18)
        titleLabel.text = Constants.StringConstants.welcome
        subTitleLabel.text = Constants.StringConstants.loginToContinue
        loginBtnRef.setTitleColor(.black, for: .normal)
        loginBtnRef.setTitle("Login ", for: .normal)
        loginBtnRef.titleLabel?.font =  .metropolisMedium(size: 16.0)
        emailText.font = .metropolisRegular(size: 16.0)
        passwordText.font = .metropolisRegular(size: 16.0)
        loginBgView.layer.cornerRadius = 8
        loginBgView.layer.borderWidth = 1.0
        loginBgView.layer.borderColor = UIColor.black.cgColor
        self.emailText.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        self.emailText.addTarget(self, action: #selector(self.emailEndEditing(_:)), for: .editingDidEnd)
        self.baseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    func validate() {
        if let name = self.emailText?.text, let email = self.emailText?.text, email.isValidEmail, name.isValidName {
            loginBtnRef.isEnabled = true
        } else {
            loginBtnRef.isEnabled = false
        }
    }
    private func validateInputs() -> Bool {
        guard let email = emailText.text, email.isValidEmail else {
            emailText.showInfo("Please enter a valid email address.")
            return false
        }
        
        if let password = passwordText.text {
            if let errorMessage = ValidationHelper.validatePassword(password) {
                passwordText.showInfo(errorMessage)
                return false
            }
        }
        
        return true
    }
    private func showLoginError() {
        let alert = UIAlertController(title: "Login Failed", message: "Invalid email or password.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func dismissBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func loginBtnAction(_ sender: UIButton) {
        guard let email = emailText.text, !email.isEmpty,
              let password = passwordText.text, !password.isEmpty else {
            return
        }
        if validateInputs() {
            if let user = CoreDataHelper.shared.fetchUser(email: email, password: password) {
                UserDefaults.standard.setValue(email, forKey: "UserID")
                ValidationHelper.moveToDashboard()
            } else {
                showLoginError()
            }
        }
    }
    
    @IBAction private func emailBeginEditing(_ sender: TweeAttributedTextField) {
        sender.lineColor = UIColor(named: "underlineColor") ?? .lightGray
        emailText.hideInfo()
    }
    
    @IBAction private func emailEndEditing(_ sender: TweeAttributedTextField) {
        if let emailText = sender.text, emailText.isValidEmail == true {
            sender.lineColor = UIColor(named: "underlineColor") ?? .lightGray
            return
        }
        if sender.text == "" {
            sender.lineColor = UIColor(named: "underlineColor") ?? .lightGray
            return
        }
        sender.lineColor = .red
        sender.showInfo("Please enter a valid email address.")
    }
    
    @IBAction private func passwordBeginEditing(_ sender: TweeAttributedTextField) {
        sender.lineColor = UIColor(named: "underlineColor") ?? .lightGray
        passwordText.hideInfo()
    }
    
    @IBAction private func passwordEndEditing(_ sender: TweeAttributedTextField) {
        if let passwordText = sender.text, let errorMessage = ValidationHelper.validatePassword(passwordText) {
            sender.lineColor = .red
            sender.showInfo(errorMessage)
        } else {
            sender.lineColor = UIColor(named: "underlineColor") ?? .lightGray
            sender.hideInfo()
        }
    }
}
extension LoginVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {
        print(#function)
        self.validate()
    }
}
