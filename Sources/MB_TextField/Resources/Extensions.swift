//
//  File.swift
//  
//
//  Created by BLIN Michael on 22/10/2021.
//

import UIKit

extension UIView {
	
	func nearestAncestor<T: UIView>(ofType type: T.Type) -> T? {
		
		if superview is T {
			
			return superview as? T
		}
		
		return superview?.nearestAncestor(ofType: type)
	}
}
