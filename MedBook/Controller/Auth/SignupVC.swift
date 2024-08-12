//
//  SignupVC.swift
//  MedBook
//
//  Created by Mohammed Sulaiman on 08/08/24.
//

import UIKit
import TweeTextField
import Reachability
import MBRadioCheckboxButton

class SignupVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var emailText: TweeAttributedTextField!
    @IBOutlet weak var passwordText: TweeAttributedTextField!
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var continueBgView: UIView!
    @IBOutlet weak var continueBtnRef: UIButton!
    @IBOutlet weak var passwordRefBtn: UIButton!
    @IBOutlet weak var check1BtnRef: CheckboxButton!
    @IBOutlet weak var check2BtnRef: CheckboxButton!
    @IBOutlet weak var check3BtnRef: CheckboxButton!
    @IBOutlet weak var condition1Label: UILabel!
    @IBOutlet weak var condition2Label: UILabel!
    @IBOutlet weak var condition3Label: UILabel!
    
    var countries = [Country]()
    var isPasswordSecured = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        // Do any additional setup after loading the view.
    }
    // MARK: - Methods
    private func setupUI() {
        titleLabel.textColor = UIColor.black
        subTitleLabel.textColor = UIColor.systemGray2
        titleLabel.font = .metropolisBold(size: 18)
        subTitleLabel.font = .metropolisBold(size: 18)
        titleLabel.text = Constants.StringConstants.welcome
        subTitleLabel.text = Constants.StringConstants.signUpToContinue
        continueBtnRef.setTitleColor(.black, for: .normal)
        continueBtnRef.setTitle("Let's go ", for: .normal)
        continueBtnRef.titleLabel?.font =  .metropolisMedium(size: 16.0)
        emailText.font = .metropolisRegular(size: 16.0)
        passwordText.font = .metropolisRegular(size: 16.0)
        continueBgView.layer.cornerRadius = 8
        continueBgView.layer.borderWidth = 1.0
        continueBgView.layer.borderColor = UIColor.black.cgColor
        self.emailText.addTarget(self, action: #selector(self.emailEndEditing(_:)), for: .editingDidEnd)
        self.baseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        self.passwordRefBtn.setImage(UIImage(named: "hide"), for: .normal)
        self.passwordText.isSecureTextEntry = true
        condition1Label.textColor = UIColor.black
        condition1Label.font = .metropolisRegular(size: 15)
        condition2Label.textColor = UIColor.black
        condition2Label.font = .metropolisRegular(size: 15)
        condition3Label.textColor = UIColor.black
        condition3Label.font = .metropolisRegular(size: 15)
        check1BtnRef.isSelected = false
        check2BtnRef.isSelected = false
        check3BtnRef.isSelected = false
        continueBtnRef.isEnabled = false
        check1BtnRef.isUserInteractionEnabled = false
        check2BtnRef.isUserInteractionEnabled = false
        check3BtnRef.isUserInteractionEnabled = false
        condition1Label.text = Constants.StringConstants.conditionText1
        condition2Label.text = Constants.StringConstants.conditionText2
        condition3Label.text = Constants.StringConstants.conditionText3
        passwordText.addTarget(self, action: #selector(passwordTextDidChange(_:)), for: .editingChanged)
    }
    
    private func loadData() {
        countries = CoreDataHelper.shared.loadCountriesFromCoreData()
        countryPicker.dataSource = self
        countryPicker.delegate = self
        
        if countries.isEmpty {
            NetworkHelper.shared.fetchCountriesData { [weak self] in
                self?.countries = CoreDataHelper.shared.loadCountriesFromCoreData()
                self?.countryPicker.reloadAllComponents()
            }
        }
        
        if let defaultCountryCode = UserDefaults.standard.string(forKey: "defaultCountryCode"),
           let index = countries.firstIndex(where: { $0.code == defaultCountryCode }) {
            countryPicker.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    
    private func validatePassword(_ password: String) {
        let isAtLeast8Characters = password.count >= 8
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasSpecialCharacter = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
        
        // Update checkboxes based on conditions
        check1BtnRef.isOn = isAtLeast8Characters
        check2BtnRef.isOn = hasUppercase
        check3BtnRef.isOn = hasSpecialCharacter
        
        continueBtnRef.isEnabled = isAtLeast8Characters && hasUppercase && hasSpecialCharacter
    }
    @objc func passwordTextDidChange(_ textField: UITextField) {
        if let password = textField.text {
            validatePassword(password)
        }
    }
    
    private func saveUserData() {
        guard let username = emailText.text, !username.isEmpty,
              let password = passwordText.text, !password.isEmpty,
              let selectedCountry = countries[countryPicker.selectedRow(inComponent: 0)].name else {
            return
        }
        if  CoreDataHelper.shared.userExists(email: username) {
            showAlert(message: "An account with this email already exists.")
            return
        }
        CoreDataHelper.shared.saveUserData(username: username, password: password, country: selectedCountry)
        UserDefaults.standard.setValue(username, forKey: "UserID")
        ValidationHelper.moveToDashboard()
    }
    
    func checkInternetConnection() {
        let reachability = try! Reachability()
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Connected via WiFi")
            } else if reachability.connection == .cellular {
                print("Connected via Cellular")
            }
        }
        
        reachability.whenUnreachable = { _ in
            DispatchQueue.main.async {
                self.showNoInternetPopup()
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func showNoInternetPopup() {
        let alert = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
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
    
    @IBAction func continueBtnAction(_ sender: UIButton) {
        saveUserData()
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
        sender.hideInfo()
    }
    
    @IBAction private func passwordBeginEditing(_ sender: TweeAttributedTextField) {
        sender.lineColor = UIColor(named: "underlineColor") ?? .lightGray
        passwordText.hideInfo()
    }
    
    @IBAction private func passwordEndEditing(_ sender: TweeAttributedTextField) {
        if let passwordText = sender.text, let errorMessage = ValidationHelper.validatePassword(passwordText) {
            sender.lineColor = .red
            sender.hideInfo()
        } else {
            sender.lineColor = UIColor(named: "underlineColor") ?? .lightGray
            sender.hideInfo()
        }
    }
    
    @IBAction func passwordBtnAction(_ sender: UIButton) {
        if isPasswordSecured {
            passwordText.isSecureTextEntry = false
            self.passwordRefBtn.setImage(UIImage(named: "view"), for: .normal)
        } else {
            passwordText.isSecureTextEntry = true
            self.passwordRefBtn.setImage(UIImage(named: "hide"), for: .normal)
        }
        isPasswordSecured = !isPasswordSecured
    }
    
    @IBAction func check1BtnAction(_ sender: CheckboxButton) {
    }
    
    @IBAction func check2BtnAction(_ sender: CheckboxButton) {
    }
    
    
    @IBAction func check3BtnAction(_ sender: CheckboxButton) {
    }
    
    
}

extension String {
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: self)
    }
    var isValidName: Bool {
        return self.count >= 3
    }
    
}
extension SignupVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row].name
    }
}
