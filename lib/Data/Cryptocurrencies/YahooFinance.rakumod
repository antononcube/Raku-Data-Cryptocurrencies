use v6.d;

use Data::ExampleDatasets;
use Data::Reshapers;
use DateTime::Grammar;
use Hash::Merge;
use LWP::Simple;

unit module Data::Cryptocurrencies::YahooFinance;

#------------------------------------------------------------

my constant $urlYahoo = "https://finance.yahoo.com/cryptocurrencies";

my constant $ledgerStart = DateTime.new(2009, 1, 3, 0, 0, 0);


#------------------------------------------------------------

my @cryptoCurrencies = ["BTC", "ETH", "USDT", "BNB", "ADA", "DOGE", "XRP", "USDC", "DOT1",
                        "HEX", "UNI3", "BCH", "LTC", "SOL1", "LINK", "THETA", "MATIC", "XLM",
                        "ICP1", "VET", "ETC", "FIL", "TRX", "XMR", "EOS"];

my @currencies = ["all", "AED", "ARS", "AUD", "BRL", "CAD", "CHF",
                  "CLP", "CNY", "COP", "CZK", "DKK", "EUR", "GBP", "HKD", "HRK",
                  "HUF", "IDR", "ILS", "INR", "IRR", "JPY", "KES", "KRW", "MXN",
                  "MYR", "NOK", "NZD", "PHP", "PKR", "PLN", "RON", "RUB", "RUR",
                  "SAR", "SEK", "SGD", "THB", "TRY", "UAH", "USD", "VEF", "XAU",
                  "ZAR"];

our sub YahooFinanceKnownCryptoCurrencies() {
    return @cryptoCurrencies;
}

our sub YahooFinanceKnownCurrencies() {
    return @currencies;
}

#------------------------------------------------------------

my %allData;

#------------------------------------------------------------

sub YahooFinanceURL(:$cryptoCurrencySymbol = 'BTC',
                    :$currencySymbol = 'USD',
                    :$endDate = now.Int,
                    :$timeUnit = '1d') {
    return "https://query1.finance.yahoo.com/v7/finance/download/$cryptoCurrencySymbol-$currencySymbol?period1=1410825600&period2=$endDate&interval=$timeUnit&events=history&includeAdjustedClose=true";
}

sub make-id(Str $ccSymbol, Str $currency) {
    return $ccSymbol ~ '_' ~ $currency;
}

#------------------------------------------------------------

our sub CryptocurrencyData(Str $ccSymbol,
                           :dates(:$date-spec) is copy = Whatever,
                           :props(:$properties) is copy = Whatever,
                           :$currency = 'USD',
                           :$format = 'hash'
                           ) {
    # Process ccSymbol
    die "The first argument is expected to be one of { @cryptoCurrencies.join(', ') }."
    unless $ccSymbol ∈ @cryptoCurrencies;

    # Process properties
    my @props =
            do given $properties {
                when Whatever { <DateTime Close> }
                when $_ ~~ Positional && $_.all ~~ Str { unique(['DateTime', |$_]) }
                when $_ ~~ Str && $_ eq 'all' { [] }
                when $_ ~~ Str { ['DateTime', $_] }
                default { [] }
            };

    if @props.elems == 0 { $properties = 'all' }

    # Process date spec
    my @dates =
            do given $date-spec {
                when Whatever { [$ledgerStart, now.Int] }
                when $_ ~~ Positional && $_.all ~~ DateTime && $_.elems ≥ 2 { $_[^2] }
                when $_ ~~ Positional && $_.all ~~ DateTime { [$_[0], $_[0]] }
                when $_ ~~ DateTime { [$ledgerStart, $_] }
            };

    # Get currency symbol
    die "The argument \$currency is expected to be one of { @currencies.join(', ') }."
    unless $currency ∈ @currencies;

    # Get data
    my @dsRes;
    do if %allData{make-id($ccSymbol, $currency)}:exists {
        @dsRes = |%allData{make-id($ccSymbol, $currency)}
    } else {

        # Retrieve all time series data
        my $url = YahooFinanceURL(cryptoCurrencySymbol => $ccSymbol, endDate => now.Int);

        my %cryptoCurrenciesData =
                do for @cryptoCurrencies -> $cc {
                    # Read
                    my $res = LWP::Simple.get(YahooFinanceURL(cryptoCurrencySymbol => $cc, endDate => now.Int));

                    # Transform
                    my @ds = csv-string-to-dataset($res, :headers);

                    # Add ID, Symbol, and DateObject
                    my $id = make-id($cc, $currency);

                    @ds = @ds.map({ merge-hash($_, %( ID => $id,
                                                      Symbol => $cc,
                                                      Currency => $currency,
                                                      DateTime => datetime-interpret($_<Date>))) });

                    # Result pair
                    $id => @ds;
                };

        # Add to data storage
        %allData = merge-hash(%allData, %cryptoCurrenciesData);

        # Retrieve
        @dsRes = |%allData{make-id($ccSymbol, $currency)}
    };


    # Filter to specs
    @dsRes = @dsRes.grep({ @dates[0].Numeric ≤ $_<DateTime>.Numeric ≤ @dates[1].Numeric });
    if !($properties ~~ Str && $properties.lc eq 'all') {
        @dsRes = select-columns(@dsRes, @props);
    }

    # Result
    return do given $format {
        when $_.isa(Whatever) || $_ ~~ Str && $_.lc ∈ <hash timeseries> {
            my $tsVal = (@props (-) <Date DateTime>).keys.head;
            my %h = @dsRes.map({ $_<DateTime> => $_{$tsVal} });
            %h
        }
        when $_ ~~ Str && $_.lc ∈ <dataset dataframe> {
            @dsRes
        }
        default {
            warn "The argument \$format is expected to be 'hash', 'dataset', or Whatever.";
            @dsRes
        }
    }
}
