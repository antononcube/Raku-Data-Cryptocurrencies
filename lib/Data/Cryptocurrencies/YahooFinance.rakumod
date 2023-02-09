use v6.d;

use Data::ExampleDatasets;
use Data::Reshapers;
use DateTime::Grammar;
use JSON::Fast;
use Hash::Merge;
use LWP::Simple;
use XDG::BaseDirectory :terms;

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

our sub KnownCryptoCurrencies() {
    return @cryptoCurrencies;
}

our sub KnownCurrencies() {
    return @currencies;
}

#------------------------------------------------------------

my %allData;

our sub AllCachedData() {
    return %allData;
}

our sub XDGDataDirectoryName() {
    my $dirName = data-home.Str ~ '/raku/Data/Cryptocurrencies';

    if not $dirName.IO.e {
        my $path = IO::Path.new($dirName);
        if not mkdir($path) {
            die "Cannot create the directory: $dirName."
        }
    }

    return $dirName;
}

our sub XDGDataFileName(Date $date) {
    return XDGDataDirectoryName() ~ '/' ~ 'YahooFinance-' ~ $date.Str ~ '.json';
}

our sub DumpCachedData(Date $date) {
    my $fname = XDGDataFileName($date);
    my %dumpData = %allData.map({ $_.key => $_.value.map({ $_<DateTime> = $_<DateTime>.Instant; $_ }).Array });
    spurt $fname, to-json(%dumpData);
}

our sub GetCachedData(Date $date -->Bool) {

    my $fname = XDGDataFileName($date);
    if $fname.IO.e {
        my $content = slurp $fname;
        my %newData = from-json($content);
        %newData = %newData.map({ $_.key => $_.value.map({ $_<DateTime> = DateTime.new($_<DateTime>); $_ }).Array });
        %allData = merge-hash(%allData, %newData);
        return True;
    }
    return False;
}


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

sub is-dates-vector($x) {
    $x ~~ Positional && ([&&] $x.map({ $_ ~~ DateTime || $_ ~~ Numeric }))
}

#------------------------------------------------------------
#| Cryptocurrencies data retrieval from Yahoo Finance.
our proto CryptocurrencyData(|) is export {*}

multi sub CryptocurrencyData(@ccSymbols, *%args) {
    my %res = @ccSymbols.map({ $_ => CryptocurrencyData($_, |%args) });
    my $format = %args<format> // 'dataset';
    given $format {
        when 'dataset' {
            my @ds;
            for %res.kv -> $k, @v { @ds.append(@v); }
            return @ds;
        }
        when 'hash' { return %res; }
        default { return %res; }
    }
}

multi sub CryptocurrencyData(Str $ccSymbol,
                             :dates(:$date-spec) is copy = Whatever,
                             :props(:$properties) is copy = Whatever,
                             :$currency = 'USD',
                             :$format = 'dataset',
                             Bool :$cache-all = False,
                             Bool :$keep = True
                             ) {
    # Process ccSymbol
    die "The first argument is expected to be one of { @cryptoCurrencies.join(', ') }."
    unless $ccSymbol ∈ @cryptoCurrencies;

    # Process properties
    my @props =
            do given $properties {
                when Whatever { <DateTime Close> }
                when $_ ~~ Positional && $_.all ~~ Str { unique(['DateTime', |$_]) }
                when 'all' { [] }
                when $_ ~~ Str { ['DateTime', $_] }
                default { [] }
            };

    if @props.elems == 0 { $properties = 'all' }

    # Process date spec
    my @dates =
            do given $date-spec {
                when is-dates-vector($_) && $_.elems ≥ 2 { $_[^2] }
                when is-dates-vector($_) { [$_[0], $_[0]] }
                when $_ ~~ DateTime { [$ledgerStart, $_] }
                default { [$ledgerStart, now.Int] }
            };

    # Get currency symbol
    die "The argument \$currency is expected to be one of { @currencies.join(', ') }."
    unless $currency ∈ @currencies;

    # Pre-load cached data
    if AllCachedData().elems == 0 && XDGDataFileName(now.DateTime.Date).IO.e {
        my $dumpGetRes = GetCachedData(now.DateTime.Date);
    }

    # Get data
    my @dsRes;
    if %allData{make-id($ccSymbol, $currency)}:exists {
        @dsRes = |%allData{make-id($ccSymbol, $currency)}
    } else {

        # Retrieve all time series data
        my %cryptoCurrenciesData =
                do for ($cache-all ?? @cryptoCurrencies !! [$ccSymbol,]) -> $cc {
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

        # Dump downloaded data
        if $cache-all && $keep {
            DumpCachedData(now.DateTime.Date);
        }

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

        when $_.isa(Whatever) || $_ ~~ Str && $_.lc ∈ <timeseries> {

            my $tsVal = (@props (-) <Date DateTime>).keys.head;
            my %h = @dsRes.map({ $_<DateTime> => $_{$tsVal} }).Hash;

            %h.pairs.sort({ $_.key }).Array;
        }

        when $_ ~~ Str && $_.lc ∈ <dataset dataframe hash> { @dsRes }

        default {
            note "The argument \$format is expected to be 'hash', 'timeseries', 'dataset', or Whatever.";
            @dsRes
        }
    }
}
