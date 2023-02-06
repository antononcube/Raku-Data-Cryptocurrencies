use v6.d;

use Data::Cryptocurrencies::YahooFinance;

unit module Data::Cryptocurrencies;

#| Cryptocurrency data retrieval.
proto cryptocurrency-data(|) is export {*}

multi sub cryptocurrency-data(Str $spec where $spec.lc ∈ <currency cryptocurrency crypto-currency>) {
    if $spec eq 'currency' {
        return Data::Cryptocurrencies::YahooFinance::KnownCurrencoes;
    } else {
        return Data::Cryptocurrencies::YahooFinance::KnownCryptoCurrency;
    }
}

multi sub cryptocurrency-data(*@args, *%args) {
    return Data::Cryptocurrencies::YahooFinance::CryptocurrencyData(|@args, |%args);
}