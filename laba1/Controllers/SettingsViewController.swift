//
//  SettingsViewController.swift
//  laba1
//
//  Created by Ольга Ерохина on 5/2/21.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var languagePicker: UIPickerView!
    
    @IBOutlet weak var settingsNavigationBar: UINavigationBar!
    
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var saveSettingsButton: UIButton!
   
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBOutlet weak var darkModeLabel: UILabel!
    var settings: Settings!

    
    private static var languagePickerDictionary: [SettingsLanguages:String] = [.en : "English", .ru : "Русский"]
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        darkModeSwitch.isOn = ThemeManager.isDarkMode()
        
        if ThemeManager.isDarkMode() {
            enableDarkMode()
        }

    }
    
    @objc func enableDarkMode() {
        let currentTheme = ThemeManager.currentTheme
        view.backgroundColor = currentTheme.backgroundColor
        languageLabel.textColor = currentTheme.textColor
        darkModeLabel.textColor = currentTheme.textColor
        saveSettingsButton.setTitleColor(currentTheme.textColor, for: .normal)
        
        settingsNavigationBar.barTintColor = currentTheme.backgroundColorForNavigationBar
        settingsNavigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: currentTheme.textColor]
//        tabBarController?.tabBar.barTintColor = currentTheme.backgroundColorForNavigationBar
    }
    
    @IBAction func darkModAction(_ sender: Any) {
        darkModeSwitch.isOn ? ThemeManager.enableDarkMode() : ThemeManager.disableDarkMode()
        let currentTheme = ThemeManager.currentTheme
        
        view.backgroundColor = currentTheme.backgroundColor
        languageLabel.textColor = currentTheme.textColor
        darkModeLabel.textColor = currentTheme.textColor
        saveSettingsButton.setTitleColor(currentTheme.textColor, for: .normal)
        
        settingsNavigationBar.barTintColor = currentTheme.backgroundColorForNavigationBar
        settingsNavigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: currentTheme.textColor]
//        tabBarController?.tabBar.barTintColor = currentTheme.backgroundColorForNavigationBar
    }
    
    @IBAction func saveSettings(_ sender: Any) {

    }
    

}

