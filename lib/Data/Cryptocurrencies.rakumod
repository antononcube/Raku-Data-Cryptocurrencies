use v6.d;

use Data::Cryptocurrencies::YahooFinance;
use Hash::Merge;

unit module Data::Cryptocurrencies;

#| Cryptocurrency data retrieval.
proto cryptocurrency-data(|) is export {*}

multi sub cryptocurrency-data(Str $spec where $spec
        .lc ∈ <currency currencies cryptocurrency cryptocurrencies crypto-currency crypto-currencies>) {
    if $spec eq 'currency' {
        return Data::Cryptocurrencies::YahooFinance::KnownCurrencies;
    } else {
        return Data::Cryptocurrencies::YahooFinance::KnownCryptoCurrencies;
    }
}

multi sub cryptocurrency-data(Str $spec where $spec.lc eq 'all', *%args) {
    return Data::Cryptocurrencies::YahooFinance::CryptocurrencyData(cryptocurrency-data('cryptocurrencies'), |%args);
}

multi sub cryptocurrency-data(Whatever, *%args) {
    return Data::Cryptocurrencies::YahooFinance::CryptocurrencyData(<BTC ETH USDT>, |%args);
}

multi sub cryptocurrency-data($spec, *%args) {
    my %newArgs = %args;
    my $format = %args<format> // 'dataset';
    if $spec ~~ Str && $format ~~ Str && $format.lc eq 'hash' {
        note "When the first argument is a string the argument format is expected to have the values 'hash', 'dataset', 'timeseries', or Whatever.";
        %newArgs<format> = 'dataset';
    }
    return Data::Cryptocurrencies::YahooFinance::CryptocurrencyData($spec, |%newArgs);
}