//
//  WelcomeVC.swift
//  MedBook
//
//  Created by Mohammed Sulaiman on 08/08/24.
//

import UIKit

class WelcomeVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var signupBgView: UIView!
    @IBOutlet weak var signupBtnRef: UIButton!
    @IBOutlet weak var loginBgView: UIView!
    @IBOutlet weak var loginBtnRef: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRootVC()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Methods
    private func setupUI() {
        titleLabel.font = .metropolisBold(size: 22.0)
        signupBgView.layer.cornerRadius = 8
        loginBgView.layer.cornerRadius = 8
        loginBgView.layer.borderWidth = 1.0
        signupBgView.layer.borderWidth = 1.0
        signupBgView.layer.borderColor = UIColor.black.cgColor
        loginBgView.layer.borderColor = UIColor.black.cgColor
        signupBtnRef.setTitle("Signup", for: .normal)
        loginBtnRef.setTitle("Login", for: .normal)
        signupBtnRef.setTitleColor(.black, for: .normal)
        loginBtnRef.setTitleColor(.black, for: .normal)
        signupBtnRef.titleLabel?.font = .metropolisMedium(size: 16.0)
        loginBtnRef.titleLabel?.font = .metropolisMedium(size: 16.0)
    }
    
    func setupRootVC() {
        if UserDefaults.standard.bool(forKey: "ISLOGGEDIN") == true {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = windowScene.windows.first {
                    let story = UIStoryboard(name: "Main", bundle: nil)
                    let vc = story.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
                    window.rootViewController = vc
                    window.makeKeyAndVisible()
                }
            }
        }
        
    }
    
    // MARK: - Actions
    @IBAction func signupBtnAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Auth", bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: String(describing: "SignupVC")) as? SignupVC else { return }
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: false)
    }
    
    @IBAction func loginBtnAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Auth", bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: String(describing: "LoginVC")) as? LoginVC else { return }
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: false)
    }
    
    
}
