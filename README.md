MB_TextField
=========

`MB_TextField` is a customizable textField for iOS swift applications. It supports differents types of fields like default, email, password, select and options like floating placeholder, mandatory etc.

## Screenshot

![Example](https://github.com/Bejil/MB_TextField/blob/main/Screenshot.png)

## Installation

### Installation via Swift Package Manager

`MB_TextField` is available through [Swift Package Manager](https://github.com/Bejil/MB_TextField).

To add `MB_TextField` as a dependency of your Swift package, simply add the following line to your `Package.swift` file:

```swift
.package(url: "https://github.com/Bejil/MB_TextField", from: "1.0.0")
```

## Usage

In order to use `MB_TextField` simply add `import MB_TextField` at the top of your swift file then use it like a normal `UITextField`:
```swift
let textField = MB_textField()
textField.placeholder = "Placeholder"
textField.autocapitalizationType = .words
textField.autocorrectionType = .no
textField.returnKeyType = .next
...
```
## Events handlers
`MB_TextField` use closures to help you manage events
```swift
textField.returnHandler = { textField in
	//User has touched the keyboard return key
}
textField.clearHandler = { textField in
	//User has touched the clear button
}
textField.changeHandler = { textField in
	//User is writting
}
textField.endHandler = { textField in
	//User has finished writing (textfield lost focus)
}
textField.beginHandler = { textField in
	//User begin writing (textField just got focus)
}
```
### Delayed changeHandler
In some cases we want to delay the changeHandler in order to prevent too frequent calls on API.
For that you can change `textField.changeDelay` (default = 0.0)

## Types

`MB_TextField` support multiple types with differents options and text validation:
 - None
 - Email
 - Password
 - Select
 
### None
Like native textField
```swift
textField.type = .none
```
With this type, textField use these default values
```swift
clearButtonMode = .whileEditing
autocapitalizationType = .sentences
autocorrectionType = .default
keyboardType = .default
returnKeyType = .done
rightViewMode = .always
```
### Email
For email address 
```swift
textField.type = .email
```
This type validate the email using this regex : `[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}` at the end of editing.

With this type, textField override the `.none` type with these values
```swift
autocapitalizationType = .none
autocorrectionType = .no
keyboardType = .emailAddress
```
### Password
For password
```swift
textField.type = .password
```
This type validate the password at the end of editing using these criterias:

 - Password has between 8 and 40 chars
 - Password has at least one lowercased char
 - Password has at least one uppercased char
 - Password has at least one special char `-_!/@#$%^&*(),.?\":{}`
 - Password has at least one numeric char

With this type, textField override the `.none` type with this value
```swift
isSecureTextEntry = true
```
### Select
For using textField like a dropdown button
```swift
textField.type = .select
```
With this type, textField isn't editable and respond to touch using this closure
```swift
textField.selectHandler = { 
	//User just tap the textField
}
```
## Customization
`MB_TextField` can be customized with these properties:

- `tintColor` affect the toolbar's buttons and the borders
 - `isValid` affect the borders
 - `isFloatingPlaceholder`affect the placeholder (native or floating)
 - `isMandatory`add a mandatory `*` to the placeholder
 - `isLoading` display a `UIActivityIndicatorView`
 - `canPaste` affect the paste possibility
 - `backgroundColor` affect the background
 - `textColor` affect the color of the text
 - `tintColor` affect the color of the cursor, the active border and the toolBar buttons
 - `invalidColor` affect the border color when field `isValid = false`
 - `mandatoryColor` affect the `*` color of the placeholder when field `isMandatory = true`
 - `borderColor` affect the default border color
 - `placeholderColor` affect the placeholder color
 - `isLoading` add a `UIActivityIndicatorView`
 - `font` the font of the main text
 - `placeholderFont` the font of the placeholder
- `mandatoryFont` the font of the `*` in the placeholder
- `mandatory` the text to add to the placeholder if `isMandatory == true`
- `toolbarFont` the font of the toolbar's buttons
 
## Override
You can override `MB_TextField` and set all of your custom valeurs in the `setUp()` function

```swift
public class CustomTextField : MB_TextField {
	
	public override func setUp() {
		
		super.setUp()
		
		placeholderFont = UIFont.boldSystemFont(ofSize: 18)
		...
	}
}
```
