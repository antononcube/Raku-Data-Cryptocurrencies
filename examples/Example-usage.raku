#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Data::Cryptocurrencies;
use Data::Reshapers;
use Data::Summarizers;
use Text::Plot;

my $tstart = now;

my @dsRes = cryptocurrency-data('BTC', props => 'all', format => 'dataset');

my $tend = now;

say "First time ingestion time: {$tend - $tstart}";


records-summary(@dsRes);

#say to-pretty-table(@dsRes.tail(90).List);
.say for @dsRes.tail(10);


$tstart = now;

my %ts = cryptocurrency-data('BTC', props => <DateTime Close>, format => 'hash');

$tend = now;
say "Second time ingestion time: {$tend - $tstart}";

say %ts.elems;
say %ts.tail(12).raku;

say text-list-plot(%ts.keys>>.DateTime>>.Numeric, %ts.values.Array, width => 160, height => 20);