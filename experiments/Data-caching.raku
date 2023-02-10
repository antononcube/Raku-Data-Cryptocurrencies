#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Data::Cryptocurrencies;
use Data::Cryptocurrencies::YahooFinance;
use Data::Reshapers;
use Data::Summarizers;
use Text::Plot;

say Data::Cryptocurrencies::YahooFinance::XDGDataDirectoryName;
say Data::Cryptocurrencies::YahooFinance::XDGDataFileName(now.DateTime.Date);

say "Data dump file exists? : {Data::Cryptocurrencies::YahooFinance::XDGDataFileName(now.DateTime.Date).IO.e}";

if ! Data::Cryptocurrencies::YahooFinance::XDGDataFileName(now.DateTime.Date).IO.e {

    say "Download data...";

    say Data::Cryptocurrencies::YahooFinance::GetCachedData(now.DateTime.Date);

    my $tstart = now;
    my @ds = cryptocurrency-data('BTC'):cache-all;

    my $tend = now;

    say "Time to download data: { $tend - $tstart }";

    #say @ds;

    say Data::Cryptocurrencies::YahooFinance::AllCachedData().keys;

    Data::Cryptocurrencies::YahooFinance::DumpCachedData(now.DateTime.Date);

    say "\t...DONE";

} else {

    say "Get dumped data...";
    my $tstart = now;
    say Data::Cryptocurrencies::YahooFinance::GetCachedData(now.DateTime.Date);
    my $tend = now;

    say "Time to ingest dumped data: { $tend - $tstart }";

    say "\t...DONE";

}


say Data::Cryptocurrencies::YahooFinance::AllCachedData().keys;
#Data::Cryptocurrencies::YahooFinance::DumpCachedData(now.DateTime.Date);
