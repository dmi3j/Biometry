//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var secretTextField: UITextField!
    @IBOutlet weak var secretLabel: UILabel!

    @IBAction func saveSecret(_ sender: Any) {
        guard let secret = secretTextField.text, secret.isEmpty == false,
            let secretData = secret.data(using: .utf8) else { return }
        guard let access =
            SecAccessControlCreateWithFlags(nil,
                                            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                            .biometryCurrentSet,
                                            nil) else { return }

        let query: [String: Any] =
            [kSecClass as String: kSecClassGenericPassword,
             kSecAttrAccessControl as String: access as Any,
             kSecValueData as String: secretData]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { return }
        secretTextField.text = nil
    }

    @IBAction func readSecret(_ sender: Any) {
        secretLabel.text = nil
        let prompt = "Auth with biometry"
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecReturnData as String: true,
                                    kSecUseOperationPrompt as String: prompt]
        var data: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &data)
        guard status == errSecSuccess else { return }
        guard let secretData = data as? Data,
              let secret = String(data: secretData, encoding: .utf8) else { return }

        secretLabel.text = secret
    }
}

