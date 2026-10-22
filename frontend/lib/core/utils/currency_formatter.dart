/// Currency-aware salary formatting utility for CareerOS.
///
/// Provides Indian Rupee (INR) and USD formatting with proper symbols,
/// number formatting, lakh/crore notation for INR, period units, and
/// safe handling of missing, negative, or invalid values.
class CurrencyFormatter {
  /// Known Indian locations/cities used to determine if salary data is INR.
  static const Set<String> _indianLocations = {
    'india',
    'bangalore',
    'bengaluru',
    'mumbai',
    'delhi',
    'new delhi',
    'hyderabad',
    'chennai',
    'pune',
    'gurgaon',
    'gurugram',
    'noida',
    'kolkata',
    'ahmedabad',
    'jaipur',
    'kochi',
    'coimbatore',
    'chandigarh',
    'indore',
  };

  /// Resolves the currency code from an explicit code or contextually from location/country.
  ///
  /// Prevents unexplained USD defaults for Indian salary queries while accurately
  /// recognizing major international regions and returning null for truly unknown currencies.
  static String? resolveCurrency({
    String? currency,
    String? location,
    String? country,
  }) {
    if (currency != null && currency.trim().isNotEmpty) {
      return currency.trim().toUpperCase();
    }

    final query = '${location ?? ''} ${country ?? ''}'.toLowerCase();
    for (final loc in _indianLocations) {
      if (query.contains(loc)) {
        return 'INR';
      }
    }

    // US locations
    if (query.contains('united states') ||
        query.contains('usa') ||
        query.contains('san francisco') ||
        query.contains('new york') ||
        query.contains('seattle') ||
        query.contains('austin') ||
        query.contains('california')) {
      return 'USD';
    }

    // UK locations
    if (query.contains('united kingdom') ||
        query.contains('uk') ||
        query.contains('london') ||
        query.contains('manchester')) {
      return 'GBP';
    }

    // European locations
    if (query.contains('germany') ||
        query.contains('france') ||
        query.contains('europe') ||
        query.contains('berlin') ||
        query.contains('paris') ||
        query.contains('amsterdam')) {
      return 'EUR';
    }

    // Canada
    if (query.contains('canada') ||
        query.contains('toronto') ||
        query.contains('vancouver')) {
      return 'CAD';
    }

    // Australia
    if (query.contains('australia') ||
        query.contains('sydney') ||
        query.contains('melbourne')) {
      return 'AUD';
    }

    // Japan
    if (query.contains('japan') || query.contains('tokyo')) {
      return 'JPY';
    }

    // Unknown currency -- do not falsely label as USD
    return null;
  }

  /// Formats a salary amount based on the currency code, including clear annual period units.
  ///
  /// For INR: uses ₹ symbol with Indian number formatting (lakhs/crores) and period (LPA / Cr / yr)
  /// For USD: uses $ symbol with K/M notation and '/ yr'
  /// For other currencies: uses generic K/M notation with currency code
  /// For unknown/null currency: formats without false currency label
  static String format(double? amount, String? currency) {
    if (amount == null || amount.isNaN || amount.isInfinite || amount < 0) {
      return '—';
    }

    if (currency == null || currency.trim().isEmpty) {
      return _formatGeneric(amount, '');
    }

    final curr = currency.trim().toUpperCase();

    switch (curr) {
      case 'INR':
        return _formatINR(amount);
      case 'USD':
        return _formatUSD(amount);
      default:
        return _formatGeneric(amount, curr);
    }
  }

  /// Compact single-line formatting suitable for charts, cards, points, and comparison bars.
  /// Always includes the correct currency symbol and unit. Does not falsely label unknown currencies as USD.
  static String formatCompact(double? amount, String? currency) {
    if (amount == null || amount.isNaN || amount.isInfinite || amount < 0) {
      return '—';
    }

    if (currency == null || currency.trim().isEmpty) {
      if (amount >= 1000000) {
        return '${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return '${(amount / 1000).toStringAsFixed(0)}K';
      } else {
        return amount.toStringAsFixed(0);
      }
    }

    final curr = currency.trim().toUpperCase();

    if (curr == 'INR') {
      if (amount >= 10000000) {
        final crores = amount / 10000000;
        return '₹${crores.toStringAsFixed(1)} Cr';
      } else if (amount >= 100000) {
        final lakhs = amount / 100000;
        return '₹${lakhs.toStringAsFixed(1)} LPA';
      } else if (amount >= 1000) {
        return '₹${(amount / 1000).toStringAsFixed(0)}K';
      } else {
        return '₹${amount.toStringAsFixed(0)}';
      }
    }

    final sym = symbol(curr);
    final prefix = sym.length == 1 ? sym : '';
    final suffix = sym.length > 1 ? ' $sym' : '';

    if (amount >= 1000000) {
      return '$prefix${(amount / 1000000).toStringAsFixed(1)}M$suffix';
    } else if (amount >= 1000) {
      return '$prefix${(amount / 1000).toStringAsFixed(0)}K$suffix';
    } else {
      return '$prefix${amount.toStringAsFixed(0)}$suffix';
    }
  }

  /// Formats INR with ₹ symbol and lakh/crore notation with clear annual period.
  /// Examples: ₹5.2 LPA, ₹18.0 LPA, ₹2.5 Cr / yr
  static String _formatINR(double amount) {
    if (amount >= 10000000) {
      // 1 crore = 10,000,000
      final crores = amount / 10000000;
      return '₹${crores.toStringAsFixed(1)} Cr / yr';
    } else if (amount >= 100000) {
      // 1 lakh = 100,000
      final lakhs = amount / 100000;
      return '₹${lakhs.toStringAsFixed(1)} LPA';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(0)}K / yr';
    } else {
      return '₹${amount.toStringAsFixed(0)} / yr';
    }
  }

  /// Formats USD with $ symbol, K/M notation, and clear annual period.
  /// Examples: $85K / yr, $150K / yr, $2.5M / yr
  static String _formatUSD(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M / yr';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K / yr';
    } else {
      return '\$${amount.toStringAsFixed(0)} / yr';
    }
  }

  /// Formats other currencies with K/M notation, currency code, and annual period.
  /// Examples: 85K EUR / yr, 2.5M GBP / yr
  static String _formatGeneric(double amount, String currency) {
    final currSuffix = currency.trim().isNotEmpty ? ' ${currency.trim()}' : '';
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M$currSuffix / yr';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K$currSuffix / yr';
    } else {
      return '${amount.toStringAsFixed(0)}$currSuffix / yr';
    }
  }

  /// Returns the currency symbol for display purposes. Returns empty string for null or empty currency.
  static String symbol(String? currency) {
    if (currency == null || currency.trim().isEmpty) return '';
    final curr = currency.trim().toUpperCase();
    switch (curr) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return curr;
    }
  }
}
