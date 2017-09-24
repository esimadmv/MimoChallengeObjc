//
//  Created by Mimohello GmbH on 16.02.17.
//  Copyright (c) 2017 Mimohello GmbH. All rights reserved.
//
	
extension SettingsViewController : SettingsTableViewCellDelegate {
	
	func switchChangedValue(switcher: UISwitch) {
		// Store darkMode status on the device
        UserDefaults.standard.set(switcher.isOn, forKey: "darkMode")
        
        // Update table based on dark mode
        self.checkDarkMode()
	}
}
