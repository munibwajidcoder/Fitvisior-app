// ============================================================
// FITVISOR SMART EMAIL VALIDATOR
// Validates syntax and detects common typos (e.g. @gmail.co instead of @gmail.com)
// ============================================================

class EmailValidator {
  /// Returns null if valid, or an error message in French if invalid.
  static String? validate(String? email) {
    if (email == null || email.trim().isEmpty) {
      return "L'adresse e-mail est obligatoire.";
    }

    final trimmed = email.trim().toLowerCase();

    // 1. Check for invalid characters or whitespace
    if (trimmed.contains(' ')) {
      return "L'adresse e-mail ne doit pas contenir d'espaces.";
    }

    // 2. Must contain exactly one '@'
    final parts = trimmed.split('@');
    if (parts.length != 2) {
      return "Format d'adresse e-mail invalide (doit contenir un @).";
    }

    final localPart = parts[0];
    final domainPart = parts[1];

    if (localPart.isEmpty) {
      return "Veuillez entrer la partie précédant le @.";
    }

    if (domainPart.isEmpty || !domainPart.contains('.')) {
      return "Domaine e-mail invalide (ex: @gmail.com).";
    }

    if (domainPart.startsWith('.') || domainPart.endsWith('.') || domainPart.contains('..')) {
      return "Format de domaine e-mail invalide.";
    }

    final domainSplit = domainPart.split('.');
    final mainDomain = domainSplit[0];
    final tld = domainSplit.sublist(1).join('.');

    // 3. TLD minimum length
    if (tld.length < 2) {
      return "Extension de domaine invalide (ex: .com, .fr).";
    }

    // 4. Common Domain Typo Detection (e.g. gmail.co -> gmail.com)
    // Gmail specifically
    if (mainDomain == 'gmail' ||
        mainDomain == 'gamil' ||
        mainDomain == 'gmial' ||
        mainDomain == 'gmai' ||
        mainDomain == 'gmaill') {
      if (mainDomain != 'gmail' || tld != 'com') {
        return "Faute de frappe détectée : vouliez-vous écrire @gmail.com ?";
      }
    }

    // Yahoo
    if (mainDomain == 'yaho' || mainDomain == 'yahooo' || mainDomain == 'yahoo') {
      if (mainDomain != 'yahoo' || (tld != 'com' && tld != 'fr')) {
        return "Faute de frappe détectée : vouliez-vous écrire @yahoo.com ?";
      }
    }

    // Hotmail / Outlook / Live
    if (mainDomain == 'hotmial' ||
        mainDomain == 'hotmai' ||
        mainDomain == 'outlok' ||
        mainDomain == 'outloo' ||
        mainDomain == 'live') {
      if (tld == 'co' || tld == 'cm' || tld == 'con') {
        return "Faute de frappe détectée : vouliez-vous écrire .com au lieu de .$tld ?";
      }
    }

    // General major provider ending with .co or .cm
    const majorProviders = {'gmail', 'hotmail', 'outlook', 'yahoo', 'icloud', 'live', 'protonmail'};
    if (majorProviders.contains(mainDomain) && (tld == 'co' || tld == 'cm' || tld == 'con')) {
      return "Faute de frappe détectée : vouliez-vous écrire @$mainDomain.com ?";
    }

    // 5. Standard RFC 5322 regex validation
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
    );

    if (!emailRegex.hasMatch(trimmed)) {
      return "Format d'adresse e-mail invalide.";
    }

    return null;
  }
}
