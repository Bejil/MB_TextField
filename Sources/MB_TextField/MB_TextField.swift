//
//  MB_TextField.swift
//
//  Created by BLIN Michaël on 17/01/2020.
//  Copyright © 2021 BLIN Michaël. All rights reserved.
//

import UIKit
import SnapKit

open class MB_TextField: UITextField {
	
	public var selectHandler:(()->Void)?
	public enum MB_TextField_Type {
		
		case none
		case email
		case password
		case select
	}
	public var type:MB_TextField_Type = .none {
		
		didSet {
			
			setUp()
		}
	}
	public override var isEnabled: Bool {
		
		didSet {
			
			alpha = isEnabled ? 1.0 : 0.5
		}
	}
	public var isEditable:Bool = true
	public var returnHandler:((MB_TextField?)->Void)?
	public var clearHandler:((MB_TextField?)->Void)?
	public var changeHandler:((MB_TextField?)->Void)?
	public var endHandler:((MB_TextField?)->Void)?
	public var beginHandler:((MB_TextField?)->Void)?
	public var canPaste: Bool = true
	public var isValid: Bool = true {
		
		didSet {
			
			updateBorder()
		}
	}
	public var isFloatingPlaceholder:Bool = true {
		
		didSet {
			
			updatePlaceholder()
		}
	}
	public override var placeholder: String? {
		
		get {
			
			return placeholderLabel.accessibilityLabel
		}
		
		set {
			
			placeholderLabel.accessibilityLabel = newValue
			updatePlaceholder()
		}
	}
	public override var text: String? {
		
		didSet {
			
			updatePlaceholder()
		}
	}
	public override var tintColor: UIColor! {
		
		didSet {
			
			toolbar.tintColor = tintColor
			updateBorder()
			updatePlaceholder()
		}
	}
	private lazy var placeholderLabel: UILabel = .init()
	public var isMandatory:Bool = false {
		
		didSet {
			
			updatePlaceholder()
		}
	}
	private lazy var toolbar: UIToolbar = {
		
		let toolbar:UIToolbar = .init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 3 * UI.Margins))
		toolbar.tintColor = tintColor
		
		let cancelBarButtonItem:UIBarButtonItem = .init(systemItem: .cancel, primaryAction: .init(handler: { [weak self] _ in
			
			UIApplication.shared.sendAction(#selector(self?.resignFirstResponder), to: nil, from: nil, for: nil)
			
		}), menu: nil)
		let cancelButtonAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Button.Navigation as Any]
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
		let doneButtonAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Button.Navigation as Any]
		doneBarButtonItem.setTitleTextAttributes(doneButtonAttributes, for: .normal)
		doneBarButtonItem.setTitleTextAttributes(doneButtonAttributes, for: .selected)
		doneBarButtonItem.setTitleTextAttributes(doneButtonAttributes, for: .highlighted)
		
		toolbar.items = [cancelBarButtonItem,flexibleSpaceBarButtonItem,doneBarButtonItem]
		
		return toolbar
	}()
	public var isLoading:Bool = false {
		
		didSet{
			
			if isLoading {
				
				let activityIndicatorView:UIActivityIndicatorView = .init(style: .medium)
				activityIndicatorView.color = Colors.Text.withAlphaComponent(0.5)
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
	private var realRightView: UIView?
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
	
	convenience init() {
		
		self.init(frame: .zero)
		
		setUp()
	}
	
	open func setUp() {
		
		layer.cornerRadius = UI.CornerRadius
		layer.borderWidth = 1.0
		tintColor = Colors.Secondary
		font = Fonts.Content.Regular
		textColor = Colors.Text
		clearButtonMode = .whileEditing
		autocapitalizationType = .sentences
		autocorrectionType = .default
		keyboardType = .default
		returnKeyType = .done
		inputAccessoryView = toolbar
		rightViewMode = .always
		backgroundColor = Colors.Background
		delegate = self
		
		addSubview(placeholderLabel)
		
		addAction(.init(handler: { [weak self] _ in
			
			self?.updatePlaceholder()
			self?.changeHandler?(self)
			
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
		
		layer.borderColor = isFirstResponder ? tintColor.cgColor : !isValid ? Colors.Red.cgColor : Colors.Text.withAlphaComponent(0.25).cgColor
	}
	
	private func updatePlaceholder() {
		
		placeholderLabel.isHidden = !isFloatingPlaceholder && !(text?.isEmpty ?? true)
		
		let placeholderState = !(text?.isEmpty ?? true)
		
		let placeholderAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Content.Regular.withSize((placeholderState && isFloatingPlaceholder) ? (Fonts.Size.Default - 5) : font?.pointSize ?? Fonts.Size.Default) as Any, .foregroundColor: isFirstResponder && isFloatingPlaceholder && !(text?.isEmpty ?? true) ? tintColor as Any : Colors.Text.withAlphaComponent(0.5) as Any]
		let placeholderAttributedString:NSMutableAttributedString = .init(string: placeholderLabel.accessibilityLabel ?? "", attributes: placeholderAttributes)
		
		if isMandatory {
			
			let mandatoryAttributes: [NSAttributedString.Key: Any] = [.font: Fonts.Content.Bold.withSize(Fonts.Size.Default - (placeholderState && isFloatingPlaceholder ? 2 : 0)) as Any, .foregroundColor: Colors.Red as Any]
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
