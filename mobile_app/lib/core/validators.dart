/// ==============================================================================
/// AgriLink Core Input Validators (Regex Pattern Library)
/// ==============================================================================
/// Strict enterprise validation rules for Auth, KYC, Banking, and Listings.
class Validators {
  // Regex Patterns
  // Strong Password: Min 8 chars, at least 1 uppercase, 1 lowercase, 1 digit, 1 special character
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#^()_\-+={}[\]:;"<>,.?/\\|~`]).{8,}$',
  );

  // Email: RFC 5322 standard email pattern
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Indian Phone Number: 10 digits starting with 6, 7, 8, or 9 (with optional +91 or 0 prefix)
  static final RegExp phoneRegex = RegExp(
    r'^(?:\+91|0)?[6-9]\d{9}$',
  );

  // Indian Pincode: 6 digits, first digit non-zero
  static final RegExp pincodeRegex = RegExp(
    r'^[1-9][0-9]{5}$',
  );

  // Indian Aadhaar Number: 12 digits (with optional spaces or dashes between groups of 4)
  static final RegExp aadhaarRegex = RegExp(
    r'^[2-9]\d{3}[\s-]?\d{4}[\s-]?\d{4}$',
  );

  // Indian PAN Card: 5 uppercase letters, 4 digits, 1 uppercase letter (e.g. ABCDE1234F)
  static final RegExp panRegex = RegExp(
    r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
  );

  // Indian Bank IFSC Code: 4 uppercase letters, 0, 6 alphanumeric (e.g. SBIN0001234)
  static final RegExp ifscRegex = RegExp(
    r'^[A-Z]{4}0[A-Z0-9]{6}$',
  );

  // Bank Account Number: 9 to 18 digits
  static final RegExp bankAccountRegex = RegExp(
    r'^\d{9,18}$',
  );

  // UPI ID: username@bank (e.g. farmer@okhdfcbank, 9876543210@paytm)
  static final RegExp upiRegex = RegExp(
    r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$',
  );

  // Positive Decimal Number (Quantity / Price)
  static final RegExp positiveNumberRegex = RegExp(
    r'^\d+(\.\d{1,2})?$',
  );

  // --------------------------------------------------------------------------
  // Validator Methods for FormField<String>
  // --------------------------------------------------------------------------

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!passwordRegex.hasMatch(value)) {
      return 'Must include uppercase, lowercase, number & special character (@#\$%!)';
    }
    return null;
  }

  /// Validates email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email address';
    }
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address (e.g. name@domain.com)';
    }
    return null;
  }

  /// Validates Indian phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your mobile number';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Enter a valid 10-digit Indian mobile number (starts with 6-9)';
    }
    return null;
  }

  /// Validates full name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters long';
    }
    return null;
  }

  /// Validates 6-digit postal pincode
  static String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a postal pincode';
    }
    if (!pincodeRegex.hasMatch(value.trim())) {
      return 'Enter a valid 6-digit Indian pincode';
    }
    return null;
  }

  /// Validates 12-digit Aadhaar Card number
  static String? validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter Aadhaar number';
    }
    if (!aadhaarRegex.hasMatch(value.trim())) {
      return 'Enter a valid 12-digit Aadhaar number (e.g. 1234 5678 9012)';
    }
    return null;
  }

  /// Validates 10-character PAN Card number
  static String? validatePAN(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter PAN number';
    }
    if (!panRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid 10-character PAN (e.g. ABCDE1234F)';
    }
    return null;
  }

  /// Validates Indian Bank IFSC code
  static String? validateIFSC(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter IFSC code';
    }
    if (!ifscRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid 11-character IFSC code (e.g. SBIN0001234)';
    }
    return null;
  }

  /// Validates Bank Account number
  static String? validateBankAccount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter bank account number';
    }
    if (!bankAccountRegex.hasMatch(value.trim())) {
      return 'Account number must be 9 to 18 digits';
    }
    return null;
  }

  /// Validates UPI ID
  static String? validateUPI(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter UPI ID';
    }
    if (!upiRegex.hasMatch(value.trim())) {
      return 'Enter a valid UPI ID (e.g. 9876543210@paytm or farmer@okhdfc)';
    }
    return null;
  }

  /// Validates positive quantity or price
  static String? validatePriceOrQuantity(String? value, {String label = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $label';
    }
    final numVal = double.tryParse(value.trim());
    if (numVal == null || numVal <= 0) {
      return 'Enter a valid positive number';
    }
    return null;
  }
}
