use v6.d;

use Data::Cryptocurrencies::YahooFinance;

unit module Data::Cryptocurrencies;

#| Cryptocurrency data retrieval.
proto cryptocurrency-data(|) is export {*}

multi sub cryptocurrency-data(Str $spec where $spec.lc ∈ <currency currencies cryptocurrency cryptocurrencies crypto-currency crypto-currencies>) {
    if $spec eq 'currency' {
        return Data::Cryptocurrencies::YahooFinance::KnownCurrencies;
    } else {
        return Data::Cryptocurrencies::YahooFinance::KnownCryptoCurrency;
    }
}

multi sub cryptocurrency-data($spec, *%args) {
    return Data::Cryptocurrencies::YahooFinance::CryptocurrencyData($spec, |%args);
}