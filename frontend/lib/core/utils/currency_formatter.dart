/// Currency-aware salary formatting utility for CareerOS.
///
/// Provides Indian Rupee (INR) and USD formatting with proper symbols,
/// number formatting, and lakh/crore notation for INR where appropriate.
class CurrencyFormatter {
  /// Formats a salary amount based on the currency code.
  ///
  /// For INR: uses ₹ symbol with Indian number formatting (lakhs/crores)
  /// For USD: uses $ symbol with K/M notation
  /// For other currencies: uses generic K/M notation with currency code
  static String format(double? amount, String? currency) {
    if (amount == null) return '—';
    
    final curr = (currency ?? 'USD').toUpperCase();
    
    switch (curr) {
      case 'INR':
        return _formatINR(amount);
      case 'USD':
        return _formatUSD(amount);
      default:
        return _formatGeneric(amount, curr);
    }
  }
  
  /// Formats INR with ₹ symbol and lakh/crore notation.
  /// Examples: ₹5.2 LPA, ₹18 LPA, ₹2.5 Cr
  static String _formatINR(double amount) {
    if (amount >= 10000000) {
      // 1 crore = 10,000,000
      final crores = amount / 10000000;
      return '₹${crores.toStringAsFixed(1)} Cr';
    } else if (amount >= 100000) {
      // 1 lakh = 100,000
      final lakhs = amount / 100000;
      return '₹${lakhs.toStringAsFixed(1)} LPA';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }
  
  /// Formats USD with $ symbol and K/M notation.
  /// Examples: $85K, $150K, $2.5M
  static String _formatUSD(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }
  
  /// Formats other currencies with K/M notation and currency code.
  /// Examples: 85K EUR, 2.5M GBP
  static String _formatGeneric(double amount, String currency) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $currency';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K $currency';
    } else {
      return '${amount.toStringAsFixed(0)} $currency';
    }
  }
  
  /// Returns the currency symbol for display purposes.
  static String symbol(String? currency) {
    final curr = (currency ?? 'USD').toUpperCase();
    switch (curr) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return curr;
    }
  }
}
