//
//  SettingsViewController.swift
//  laba1
//
//  Created by Ольга Ерохина on 5/2/21.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var languagePicker: UIPickerView!
    
    @IBOutlet weak var settingsNavigationBar: UINavigationBar!
    
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var saveSettingsButton: UIButton!
   
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var setThemeButton: UIButton!
    
    @IBOutlet weak var fontPicker: UIPickerView!
    @IBOutlet weak var fontSizeLabel: UILabel!
    
    private var changedTheme: UIColor?
    var pickerData: [String] = [String]()
    var langPickerData: [String] = [String]()
    var fontSize: CGFloat?
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeLabels), name: .languageChanged, object: nil)
        
        darkModeSwitch.isOn = ThemeManager.isDarkMode()
        
        if ThemeManager.isDarkMode() {
            enableDarkMode()
        }

        if Auth.auth().currentUser != nil {
            signOutButton.setTitle("Logout", for: .normal)
        } else {
            signOutButton.setTitle("Login", for: .normal)
        }
        
        if changedTheme != nil {
            enableDarkMode()
        }
        
        languagePicker.delegate = self
        languagePicker.dataSource = self
        langPickerData = ["English", "Русский"]
        
        fontPicker.delegate = self
        fontPicker.dataSource = self
        pickerData = ["13" , "14", "15", "16", "17", "18", "19", "20", "21", "22"]
        fontPicker.selectRow(5, inComponent: 0, animated: true)
    }
    
    
    @objc func enableDarkMode() {
        let currentTheme = ThemeManager.setCurrentTheme(changedTheme)
        view.backgroundColor = currentTheme.backgroundColor
        languageLabel.textColor = currentTheme.textColor
        darkModeLabel.textColor = currentTheme.textColor
        saveSettingsButton.setTitleColor(currentTheme.textColor, for: .normal)
        
        settingsNavigationBar.barTintColor = currentTheme.backgroundColorForNavigationBar
        
        if fontSize == nil { fontSize = 17.0}
        let attributes = [
          NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize!),
            NSAttributedString.Key.foregroundColor: currentTheme.textColor
        ]
        settingsNavigationBar.titleTextAttributes = attributes
        
        signOutButton.setTitleColor(currentTheme.textColor, for: .normal)
        setThemeButton.setTitleColor(currentTheme.textColor, for: .normal)
        fontSizeLabel.textColor = currentTheme.textColor
        fontPicker.reloadAllComponents()
        languagePicker.reloadAllComponents()
//        tabBarController?.tabBar.barTintColor = currentTheme.backgroundColorForNavigationBar
    }
    
    @IBAction func darkModAction(_ sender: Any) {
        darkModeSwitch.isOn ? ThemeManager.enableDarkMode() : ThemeManager.disableDarkMode()
        let currentTheme = ThemeManager.setCurrentTheme(changedTheme)
        
        view.backgroundColor = currentTheme.backgroundColor
        languageLabel.textColor = currentTheme.textColor
        darkModeLabel.textColor = currentTheme.textColor
        saveSettingsButton.setTitleColor(currentTheme.textColor, for: .normal)
        
        settingsNavigationBar.barTintColor = currentTheme.backgroundColorForNavigationBar
        
        if fontSize == nil { fontSize = 17.0}
        let attributes = [
          NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize!),
            NSAttributedString.Key.foregroundColor: currentTheme.textColor
        ]
        settingsNavigationBar.titleTextAttributes = attributes
        
        signOutButton.setTitleColor(currentTheme.textColor, for: .normal)
        setThemeButton.setTitleColor(currentTheme.textColor, for: .normal)
        fontSizeLabel.textColor = currentTheme.textColor
        fontPicker.reloadAllComponents()
        languagePicker.reloadAllComponents()

//        tabBarController?.tabBar.barTintColor = currentTheme.backgroundColorForNavigationBar
    }

    @objc func changeLabels() {
        languageLabel.text = "Language".localized()
        darkModeLabel.text = "Dark Mode".localized()
        fontSizeLabel.text = "Font Size".localized()
        
        
        saveSettingsButton.setTitle("Save settings".localized(), for: .normal)
//        saveSettingsButton.titleLabel?.text = "Save settings".localized()
        setThemeButton.setTitle("Set Theme".localized(), for: .normal)
        if signOutButton.titleLabel?.text == "Logout" || signOutButton.titleLabel?.text == "Выйти" {
            signOutButton.setTitle("Logout".localized(), for: .normal)
        } else {
            signOutButton.setTitle("Login".localized(), for: .normal)
        }
        
        settingsNavigationBar.topItem?.title = "Settings".localized()
        
        tabBarController?.tabBar.items?.forEach({ (item) in
            if item.title == "Settings" || item.title == "Настройки" {
                item.title = "Settings".localized()
            }
            
            if item.title == "Map" || item.title == "Карта" {
                item.title = "Map".localized()
            }
            
            if item.title == "Library" || item.title == "Библиотека" {
                item.title = "Library".localized()
            }
        })
    }
    
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
       do {
         try firebaseAuth.signOut()
       } catch let signOutError as NSError {
         print ("Error signing out: %@", signOutError)
       }
        
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func setThemeTapped(_ sender: Any) {
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        colorPickerVC.supportsAlpha = false
        present(colorPickerVC, animated: true)
    }
    
    @IBAction func saveSettings(_ sender: Any) {

    }
}

extension SettingsViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        let changedColor = ["color" : color]
        NotificationCenter.default.post(name: .changedColor, object: self, userInfo: changedColor)
        ThemeManager.disableDarkMode()
        changedTheme = color
        enableDarkMode()
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        changedTheme = color
        enableDarkMode()
    }
    
}

extension SettingsViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == fontPicker {
            return pickerData.count
        } else {
            return langPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == fontPicker {
            return pickerData[row]
        } else {
            return langPickerData[row]
        }
    }
    
}

extension SettingsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == fontPicker {

            let fontSize = CGFloat(Float(pickerData[row])!)
            self.fontSize = fontSize
            
            fontSizeLabel.font = fontSizeLabel.font.withSize(fontSize)
            languageLabel.font = languageLabel.font.withSize(fontSize)
            darkModeLabel.font = darkModeLabel.font.withSize(fontSize)
            
            signOutButton.titleLabel?.font = signOutButton.titleLabel?.font.withSize(fontSize)
            setThemeButton.titleLabel?.font = setThemeButton.titleLabel?.font.withSize(fontSize)
            saveSettingsButton.titleLabel?.font = saveSettingsButton.titleLabel?.font.withSize(fontSize)
            
            
            let attributes = [
              NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedString.Key.foregroundColor: ThemeManager.setCurrentTheme(changedTheme).textColor
            ]
            
            settingsNavigationBar.titleTextAttributes = attributes
            
            
            UINavigationBar.appearance().titleTextAttributes = attributes
            
            let changedFontSize = ["fontSize" : fontSize]
            NotificationCenter.default.post(name: .fontChanged, object: self, userInfo: changedFontSize)
        } else {
            if langPickerData[row] == "English" {
                Bundle.setLanguage(lang: "en")
            } else {
                Bundle.setLanguage(lang: "ru")
            }
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
        
        
    }
    

    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if pickerView == fontPicker {
            var pickerLabel: UILabel? = (view as? UILabel)
            if pickerLabel == nil {
                pickerLabel = UILabel()
                pickerLabel?.font = pickerLabel?.font.withSize(CGFloat(Float(pickerData[row])!))
                pickerLabel?.textAlignment = .center
            }
            pickerLabel?.text = pickerData[row]
            let currentTheme = ThemeManager.setCurrentTheme(changedTheme)
            pickerLabel?.textColor = currentTheme.textColor
        
            return pickerLabel!
        } else {
            var pickerLabel: UILabel? = (view as? UILabel)
            if pickerLabel == nil {
                pickerLabel = UILabel()
//                pickerLabel?.font = pickerLabel?.font.withSize(CGFloat(Float(pickerData[row])!))
                pickerLabel?.textAlignment = .center
            }
            pickerLabel?.text = langPickerData[row]
            let currentTheme = ThemeManager.setCurrentTheme(changedTheme)
            pickerLabel?.textColor = currentTheme.textColor
        
            return pickerLabel!
        }
    }
    
}

extension Notification.Name {
    static let changedColor = Notification.Name("changedColor")
    static let fontChanged = Notification.Name("fontSizeChanged")
    
}


