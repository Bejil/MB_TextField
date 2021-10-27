//
//  MB_TextField.swift
//
//  Created by BLIN Michaël on 17/01/2020.
//  Copyright © 2021 BLIN Michaël. All rights reserved.
//

import UIKit
import SnapKit

open class MB_TextField: UITextField {
	
	//MARK: - Colors
	/**
	 Global tint color for cursors, active border and toolbar buttons
	 */
	public override var tintColor: UIColor! {
		
		didSet {
			
			inputAccessoryView = getToolbar()
			updateBorder()
			updatePlaceholder()
		}
	}
	/**
	 Color the `*` in the placeholder when `isMandatory = true`
	 - Note: Default value is `UIColor.red`
	 */
	public var mandatoryColor:UIColor = .red {
		
		didSet {
			
			updatePlaceholder()
		}
	}
	/**
	 Color the borders when `isValid = false`
	 - Note: Default value is `UIColor.red`
	 */
	public var invalidColor:UIColor = .red {
		
		didSet {
			
			updateBorder()
		}
	}
	/**
	 Color the borders
	 - Note: Default value is `UIColor.darkText.withAlphaComponent(0.25)`
	 */
	public var borderColor: UIColor = UIColor.darkText.withAlphaComponent(0.25) {
		
		didSet {
			
			updateBorder()
		}
	}
	/**
	 Color the placeholder text
	 - Note: Default value is `UIColor.darkText.withAlphaComponent(0.5)`
	 */
	public var placeholderColor: UIColor = UIColor.darkText.withAlphaComponent(0.5) {
		
		didSet {
			
			updatePlaceholder()
		}
	}
	
	//MARK: - Types
	/**
	 Defines the possible types of the textField

	 - none: Like native UITextField
	 - email: For email textField
	 - password: For email textField
	 - select: For using textField like a dropdown button
	 
	 When `type = .email`, the value is validated at the end of editing with this regex: `[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}` at the end of editing.
	 
	 When `type = .password`, the value is validated at the end of editing using these criterias:

	  - Password has between 8 and 40 chars
	  - Password has at least one lowercased char
	  - Password has at least one uppercased char
	  - Password has at least one special char `-_!/@#$%^&*(),.?\":{}`
	  - Password has at least one numeric char
	 */
	public enum MB_TextField_Type {
		
		case none
		case email
		case password
		case select
	}
	/**
	 Defines the current type of the textField
	 - Note: Default value is `.none`
	 */
	public var type:MB_TextField_Type = .none {
		
		didSet {
			
			setUp()
		}
	}
	///Defines the closure to be called when `type = .select` and textField is touched
	public var selectHandler:(()->Void)?
	
	//MARK: - Common closure
	///Closure called when user touch keyboard's return key
	public var returnHandler:((MB_TextField?)->Void)?
	///Closure called when user touch the clear button
	public var clearHandler:((MB_TextField?)->Void)?
	///Closure called when user is writting and change the text
	public var changeHandler:((MB_TextField?)->Void)?
	/**
	 Seconds before the `changeClosure` is called
	 - Note: Default value is `0.0`
	 */
	public var changeDelay:Double = 0.0
	///Closure called when user end editing
	public var endHandler:((MB_TextField?)->Void)?
	///Closure called when user begin editing
	public var beginHandler:((MB_TextField?)->Void)?
	
	//MARK: - States
	/**
	 Defines if the textField is enabled or not
	 - Note: Default value is `true`. This alter the alpha of the field: `1.0` if true, `0.5` if false
	 */
	public override var isEnabled: Bool {
		
		didSet {
			
			alpha = isEnabled ? 1.0 : 0.5
		}
	}
	/**
	 Defines if the textField can be edited or not
	 - Note: Default value is `true`
	 */
	public var isEditable:Bool = true
	/**
	 Defines if the user can paste text in the textField
	 - Note: Default value is `true`
	 */
	public var canPaste: Bool = true
	/**
	 Defines if the text is valid or not
	 - Note: Default value is `true`. This alter the border color of the field
	 */
	public var isValid: Bool = true {
		
		didSet {
			
			updateBorder()
		}
	}
	/**
	 Defines the style of the placeholder.
	 If `true`, the placeholder will be at the top of the text when editing.
	 If `false`, le the placeholder will disappear when editing.
	 - Note: Default value is `true`
	 */
	public var isFloatingPlaceholder:Bool = true {
		
		didSet {
			
			updatePlaceholder()
		}
	}
	/**
	 Defines if the textField is mandatory or not.
	 If `true`, an `*` (colored be `mandatoryColor`) is added to the placeholder.
	 - Note: Default value is `false`
	 */
	public var isMandatory:Bool = false {
		
		didSet {
			
			updatePlaceholder()
		}
	}
	/**
	 Defines if the textField is loading or not
	 If `true`, a `UIActivityIndicatorView` (colored with `textColor`) is added.
	 Use `false` to remove it.
	 - Note: Default value is `false`
	 */
	public var isLoading:Bool = false {
		
		didSet{
			
			if isLoading {
				
				let activityIndicatorView:UIActivityIndicatorView = .init(style: .medium)
				activityIndicatorView.color = textColor
				activityIndicatorView.startAnimating()
				
				let loadingView:UIView = .init()
				loadingView.addSubview(activityIndicatorView)
				
				activityIndicatorView.snp.makeConstraints { (make) in
					make.top.bottom.left.equalToSuperview()
					make.right.equalToSuperview().inset(UI.Margins)
				}
				
				rightView = loadingView
			}
			else{
				
				rightView = realRightView
			}
		}
	}
	
	//MARK: - Values
	///The placeholder value
	public override var placeholder: String? {
		
		get {
			
			return placeholderLabel.accessibilityLabel
		}
		
		set {
			
			placeholderLabel.accessibilityLabel = newValue
			updatePlaceholder()
		}
	}
	///The textField value
	public override var text: String? {
		
		didSet {
			
			updatePlaceholder()
		}
	}
	
	//MARK: - Fonts
	/**
	 Defines the font of the placeholder.
	 - Note: The size depends on `isFloatingPlaceholder`.
	 Default value is `UIFont.systemFont(ofSize: 14)`
	 */
	public var placeholderFont:UIFont = UIFont.systemFont(ofSize: Fonts.Size.Default) {
		
		didSet {
			
			updatePlaceholder()
		}
	}
	/**
	 Defines the font of the mandatory `*`.
	 - Note: The size depends on `isFloatingPlaceholder`.
	 Default value is `UIFont.boldSystemFont(ofSize: 14)`
	 */
	public var mandatoryFont:UIFont = UIFont.boldSystemFont(ofSize: Fonts.Size.Default) {
		
		didSet {
			
			updatePlaceholder()
		}
	}
	/**
	 Defines the font of the toolbar's buttons.
	 - Note: Default value is `UIFont.systemFont(ofSize: 13)`
	 */
	public var toolbarFont:UIFont = UIFont.systemFont(ofSize: Fonts.Size.Default-1) {
		
		didSet {
			
			inputAccessoryView = getToolbar()
		}
	}
	
	//MARK: - UI Elements
	//MARK: Public
	public override var rightView: UIView? {
		
		didSet {
			
			realRightView = rightView
			layoutIfNeeded()
			layoutSubviews()
		}
	}
	public override var leftView: UIView? {
		
		didSet {
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
				
				self?.updatePlaceholder()
			}
		}
	}
	//MARK: Private
	private lazy var placeholderLabel: UILabel = .init()
	private var realRightView: UIView?
	
	convenience init() {
		
		self.init(frame: .zero)
		
		setUp()
	}
	
	///Override this function to customize the textField
	open func setUp() {
		
		layer.cornerRadius = UI.CornerRadius
		layer.borderWidth = 1.0
		clearButtonMode = .whileEditing
		autocapitalizationType = .sentences
		autocorrectionType = .default
		keyboardType = .default
		returnKeyType = .done
		inputAccessoryView = getToolbar()
		rightViewMode = .always
		delegate = self
		
		addSubview(placeholderLabel)
		
		addAction(.init(handler: { [weak self] _ in
			
			self?.updatePlaceholder()
			
			DispatchQueue.main.asyncAfter(deadline: .now() + (self?.changeDelay ?? 0.0)) { [weak self] in
				
				self?.changeHandler?(self)
			}
			
		}), for: .editingChanged)
		
		addAction(.init(handler: { [weak self] _ in
			
			self?.isValid = true
			self?.updatePlaceholder()
			
		}), for: .editingDidBegin)
		
		addAction(.init(handler: { [weak self] _ in
			
			self?.updateBorder()
			self?.updatePlaceholder()
			
		}), for: .editingDidEnd)
		
		updateBorder()
		updatePlaceholder()
		
		snp.makeConstraints { make in
			
			make.height.equalTo(50)
		}
		
		if type == .email {
			
			placeholder = String(key: "textFields_email_placeholder")
			isMandatory = true
			autocapitalizationType = .none
			autocorrectionType = .no
			keyboardType = .emailAddress
			
			endHandler = { [weak self] _ in
				
				self?.isValid = self?.text?.isValidEmail ?? false
			}
		}
		else if type == .password {
			
			placeholder = String(key: "textFields_password_placeholder")
			isMandatory = true
			isSecureTextEntry = true
			
			endHandler = { [weak self] _ in
				
				self?.isValid = self?.text?.isValidPassword ?? false
			}
		}
		else if type == .select {
			
			isEditable = false
			
			let view:UIView = .init()
			let imageView:UIImageView = .init(image: UIImage(systemName: "chevron.down.square.fill"))
			view.addSubview(imageView)
			imageView.snp.makeConstraints { make in
				make.top.bottom.left.equalToSuperview()
				make.right.equalToSuperview().inset(UI.Margins)
			}
			rightView = view
			
			let button:UIButton = .init()
			button.addAction(.init(handler: { [weak self] _ in

				self?.selectHandler?()
				
			}), for: .touchUpInside)
			addSubview(button)
			button.snp.makeConstraints { make in
				make.edges.equalToSuperview()
			}
		}
	}
	
	open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateBorder()
	}
	
	private func rect(forBounds bounds: CGRect) -> CGRect {
		
		var lc_frame:CGRect = .init()
		lc_frame.origin.x = (leftView?.frame.size.width ?? 0) + (UI.Margins/2)
		lc_frame.origin.y = text?.isEmpty ?? true || !isFloatingPlaceholder ? UI.Margins/2 : placeholderLabel.frame.maxY
		lc_frame.size.width = bounds.size.width - lc_frame.origin.x - (rightView != nil ? (rightView?.frame.size.width ?? 0) + (UI.Margins/2) : 0) - (UI.Margins/2)
		lc_frame.size.height = bounds.size.height - (text?.isEmpty ?? true || !isFloatingPlaceholder ? (2 * lc_frame.origin.y) : placeholderLabel.frame.maxY + placeholderLabel.frame.origin.y)
		return lc_frame
	}
	
	public override func textRect(forBounds bounds: CGRect) -> CGRect {
		
		var lc_frame = rect(forBounds: bounds)
		lc_frame.size.width -= clearButtonMode == .always ? 1.5*UI.Margins :  0
		return lc_frame
	}
	
	public override func editingRect(forBounds bounds: CGRect) -> CGRect {
		
		var lc_frame = rect(forBounds: bounds)
		lc_frame.size.width -= clearButtonMode == .whileEditing ? 1.5*UI.Margins :  0
		return lc_frame
	}
	
	public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		
		if action == #selector(UIResponderStandardEditActions.paste(_:)) {
			
			return canPaste
		}
		
		return super.canPerformAction(action, withSender: sender)
	}
	
	private func updateBorder() {
		
		layer.borderColor = isFirstResponder ? tintColor.cgColor : !isValid ? invalidColor.cgColor : borderColor.cgColor
	}
	
	private func updatePlaceholder() {
		
		placeholderLabel.isHidden = !isFloatingPlaceholder && !(text?.isEmpty ?? true)
		
		let placeholderState = !(text?.isEmpty ?? true)
		
		let placeholderAttributes: [NSAttributedString.Key: Any] = [.font: placeholderFont.withSize((placeholderState && isFloatingPlaceholder) ? (Fonts.Size.Default - 5) : font?.pointSize ?? Fonts.Size.Default) as Any, .foregroundColor: isFirstResponder && isFloatingPlaceholder && !(text?.isEmpty ?? true) ? tintColor as Any : placeholderColor as Any]
		let placeholderAttributedString:NSMutableAttributedString = .init(string: placeholderLabel.accessibilityLabel ?? "", attributes: placeholderAttributes)
		
		if isMandatory {
			
			let mandatoryAttributes: [NSAttributedString.Key: Any] = [.font: mandatoryFont.withSize(Fonts.Size.Default - (placeholderState && isFloatingPlaceholder ? 2 : 0)) as Any, .foregroundColor: mandatoryColor as Any]
			placeholderAttributedString.append(.init(string: " ﹡", attributes: mandatoryAttributes))
		}
		
		placeholderLabel.attributedText = placeholderAttributedString
		
		UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut) {
			
			self.placeholderLabel.snp.removeConstraints()
			
			if self.placeholderLabel.superview != nil {
				
				self.placeholderLabel.snp.makeConstraints { make in
					
					make.left.equalToSuperview().inset((self.leftView?.frame.size.width ?? 0) + (UI.Margins/2))
					make.right.equalToSuperview().inset(UI.Margins/2 + (self.frame.size.width - (self.editingRect(forBounds: self.frame).size.width + self.editingRect(forBounds: self.frame).origin.y)))
					
					if placeholderState && self.isFloatingPlaceholder {
						
						make.top.equalToSuperview().inset(UI.Margins/2)
					}
					else{
						
						make.centerY.equalToSuperview()
					}
				}
			}
			
			self.layoutIfNeeded()
		}
	}
	
	private func getToolbar() -> UIToolbar {
		
		let toolbar:UIToolbar = .init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 3 * UI.Margins))
		toolbar.tintColor = tintColor
		
		let cancelBarButtonItem:UIBarButtonItem = .init(systemItem: .cancel, primaryAction: .init(handler: { [weak self] _ in
			
			UIApplication.shared.sendAction(#selector(self?.resignFirstResponder), to: nil, from: nil, for: nil)
			
		}), menu: nil)
		let cancelButtonAttributes: [NSAttributedString.Key: Any] = [.font: toolbarFont as Any]
		cancelBarButtonItem.setTitleTextAttributes(cancelButtonAttributes, for: .normal)
		cancelBarButtonItem.setTitleTextAttributes(cancelButtonAttributes, for: .selected)
		cancelBarButtonItem.setTitleTextAttributes(cancelButtonAttributes, for: .highlighted)
		
		let flexibleSpaceBarButtonItem:UIBarButtonItem = .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		
		let doneBarButtonItem:UIBarButtonItem = .init(systemItem: .done, primaryAction: .init(handler: { [weak self] _ in
			
			UIApplication.shared.sendAction(#selector(self?.resignFirstResponder), to: nil, from: nil, for: nil)
			
			if let strongSelf = self {
				
				_ = strongSelf.delegate?.textFieldShouldReturn?(strongSelf)
			}
			
		}), menu: nil)
		let doneButtonAttributes: [NSAttributedString.Key: Any] = [.font: toolbarFont as Any]
		doneBarButtonItem.setTitleTextAttributes(doneButtonAttributes, for: .normal)
		doneBarButtonItem.setTitleTextAttributes(doneButtonAttributes, for: .selected)
		doneBarButtonItem.setTitleTextAttributes(doneButtonAttributes, for: .highlighted)
		
		toolbar.items = [cancelBarButtonItem,flexibleSpaceBarButtonItem,doneBarButtonItem]
		
		return toolbar
	}
}

extension MB_TextField : UITextFieldDelegate {
	
	public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		
		return isEditable
	}
	
	open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		returnHandler?(self)
		
		return false
	}
	
	open func textFieldShouldClear(_ textField: UITextField) -> Bool {
		
		clearHandler?(self)
		
		return true
	}
	
	public func textFieldDidBeginEditing(_ textField: UITextField) {
		
		if let scrollView = nearestAncestor(ofType: UIScrollView.self), let origin = superview?.convert(frame.origin, to: scrollView) {
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				
				scrollView.setContentOffset(.init(x: 0, y: scrollView.contentSize.height > scrollView.frame.size.height && (origin.y - UI.Margins) + scrollView.frame.size.height > scrollView.contentSize.height ? scrollView.contentSize.height - scrollView.frame.size.height : origin.y - UI.Margins), animated: true)
			}
		}
		
		beginHandler?(self)
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField) {
		
		endHandler?(self)
	}
}
