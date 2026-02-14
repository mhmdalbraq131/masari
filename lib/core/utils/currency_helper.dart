enum CurrencyType {
  yer,
  sar,
}

class CurrencyHelper {
  static const double _yerToSarRate = 0.0067; // mock fixed rate

  static CurrencyType defaultCurrency() => CurrencyType.yer;

  static double convert({
    required double amount,
    required CurrencyType from,
    required CurrencyType to,
  }) {
    if (from == to) return amount;
    if (from == CurrencyType.yer && to == CurrencyType.sar) {
      return amount * _yerToSarRate;
    }
    if (from == CurrencyType.sar && to == CurrencyType.yer) {
      return amount / _yerToSarRate;
    }
    return amount;
  }

  static String format(double amount, CurrencyType currency) {
    final value = amount.toStringAsFixed(currency == CurrencyType.sar ? 2 : 0);
    return currency == CurrencyType.sar ? '$value ر.س' : '$value ر.ي';
  }

  static CurrencyType toggle(CurrencyType current) {
    return current == CurrencyType.yer ? CurrencyType.sar : CurrencyType.yer;
  }
}
