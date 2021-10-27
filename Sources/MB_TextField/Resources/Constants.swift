//
//  File.swift
//  
//
//  Created by BLIN Michael on 22/10/2021.
//

import UIKit

struct UI {
	
	static let Margins:CGFloat = 15.0
	static let CornerRadius:CGFloat = Margins/2
}

struct Fonts {
	
	struct Name {
		
		static let Regular:String = "NunitoSans-Regular"
		static let Bold:String = "NunitoSans-Bold"
	}
	
	struct Size {
		
		static let Default:CGFloat = 14.0
	}
	
	struct Content {
		
		static let Regular:UIFont = UIFont(name: Fonts.Name.Regular, size: Fonts.Size.Default)!
		static let Bold:UIFont = UIFont(name: Fonts.Name.Bold, size: Fonts.Size.Default)!
	}
	
	struct Button {
		
		static let Navigation:UIFont = UIFont(name: Fonts.Name.Regular, size: Fonts.Size.Default-1)!
	}
}
