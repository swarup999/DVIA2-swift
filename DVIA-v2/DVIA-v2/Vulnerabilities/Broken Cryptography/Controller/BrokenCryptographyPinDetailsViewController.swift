//
//  BrokenCryptographyPinDetailsViewController.swift
//  DVIA-v2
//
//  Created by Prateek Gianchandani on 4/4/18.
//  Copyright © 2018 HighAltitudeHacks. All rights reserved.
//

import UIKit

class BrokenCryptographyPinDetailsViewController: UIViewController {

    @IBOutlet weak var returningUserView: UIView!
    @IBOutlet weak var firstTimeUserView: UIView!
    @IBOutlet weak var welcomeReturningUserLabel: UILabel!
    @IBOutlet weak var returningUserPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loggedInLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BrokenCryptographyPinDetailsViewController: UITextFieldDelegate {
    
    func pbkdf2(password: String, salt: Data, keyByteCount: Int, rounds: Int) -> Data? {
    
        let passwordData = password.data(using:String.Encoding.utf8)!
        var derivedKeyData = Data(repeating:0, count:keyByteCount)
        
        let derivationStatus = derivedKeyData.withUnsafeMutableBytes {derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                //Could also use SHA256 or SHA512 :/
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    password, passwordData.count,
                    saltBytes, salt.count,
                    CCPBKDFAlgorithm(kCCPRFHmacAlgSHA1),
                    UInt32(rounds),
                    derivedKeyBytes, derivedKeyData.count)
            }
        }
        if (derivationStatus != 0) {
            print("Error: \(derivationStatus)")
            return nil;
        }
        
        return derivedKeyData
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let salt = Data(bytes: [0x65, 0x62, 0x6f, 0xf2, 0xff, 0x44, 0x7a, 0xc6])
        let keyByteCount = 16
        //Could be 100000 :/
        let rounds = 100
        let dataPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!).appendingPathComponent("/passcode-data").absoluteURL
        if textField == passwordTextField {
            textField.resignFirstResponder()
            if textField.text == nil {
                DVIAUtilities.showAlert(title: "Oops", message: "Please enter a password", viewController: self)
            } else {
                let encryptedData = pbkdf2(password:textField.text!, salt:salt, keyByteCount:keyByteCount, rounds:rounds)
                print("encryptedDatga (SHA1): \(encryptedData! as NSData)")
                try? encryptedData?.write(to: dataPath, options: .atomic)
                UserDefaults.standard.set(true, forKey: "loggedIn")
                UserDefaults.standard.synchronize()
                firstTimeUserView.isHidden = true
            }
        } else if textField == returningUserPasswordTextField {
            let data = returningUserPasswordTextField.text?.data(using: String.Encoding.utf8)
            let encryptedData = try? Data(contentsOf: dataPath)
            let decryptedData = try? RNDecryptor.decryptData(encryptedData, withPassword: "@daloq3as$qweasdlasasjdnj")
            if data == decryptedData {
                loggedInLabel.isHidden = false
                returningUserPasswordTextField.isHidden = true
                welcomeReturningUserLabel.isHidden = true
            } else {
                DVIAUtilities.showAlert(title: "Oops", message: "Password is incorrect", viewController: self)
                return false
            }
        }
        return false
    }
}
