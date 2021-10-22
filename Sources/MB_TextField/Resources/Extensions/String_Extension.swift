//
//  String_Extension.swift
//  FigaroEmploi
//
//  Created by BLIN Michael on 07/06/2021.
//

import Foundation

extension String {
	
	init(key:String) {
		
		self = NSLocalizedString(key, comment:"localizable string")
	}
	
	var isValidEmail: Bool {
		
		let string:String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
		let predicate:NSPredicate = .init(format: "SELF MATCHES %@", string)
		return predicate.evaluate(with: self)
	}
	
	var isValidPassword: Bool {
		
		return isValidPasswordMinCharacters && isValidPasswordLowercaseCharacter && isValidPasswordUppercaseCharacter && isValidPasswordSpecialCharacter && isValidPasswordNumericCharacter
	}
	
	var isValidPasswordMinCharacters: Bool {
		
		return count >= 8 && count <= 40
	}
	
	var isValidPasswordLowercaseCharacter: Bool {
		
		let string:String = ".*[a-z]+.*"
		let predicate:NSPredicate = .init(format: "SELF MATCHES %@", string)
		return predicate.evaluate(with: self)
	}
	
	var isValidPasswordUppercaseCharacter: Bool {
		
		let string:String = ".*[A-Z]+.*"
		let predicate:NSPredicate = .init(format: "SELF MATCHES %@", string)
		return predicate.evaluate(with: self)
	}
	
	var isValidPasswordSpecialCharacter: Bool {
		
		let string:String = ".*[-_!/@#$%^&*(),.?\":{}]+.*"
		let predicate:NSPredicate = .init(format: "SELF MATCHES %@", string)
		return predicate.evaluate(with: self)
	}
	
	var isValidPasswordNumericCharacter: Bool {
		
		let string:String = ".*[0-9]+.*"
		let predicate:NSPredicate = .init(format: "SELF MATCHES %@", string)
		return predicate.evaluate(with: self)
	}
}
