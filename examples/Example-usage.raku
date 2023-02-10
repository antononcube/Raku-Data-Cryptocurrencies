#!/usr/bin/env raku
use v6.d;

use Data::Cryptocurrencies;
use Data::Reshapers;
use Data::Summarizers;
use Text::Plot;

my $tstart = now;

my @dsRes = cryptocurrency-data('BTC', props => 'all', format => 'dataset'):!cache-all;

my $tend = now;

say "First time ingestion time: { $tend - $tstart }";


records-summary(@dsRes);

#say to-pretty-table(@dsRes.tail(90).List);
.say for @dsRes.tail(10);


$tstart = now;

my @dsTS = cryptocurrency-data('BTC', props => <DateTime Close>, dates => (DateTime.new(2020, 1, 1, 0, 0, 0), now), format => 'dataset');

$tend = now;
say "Second time ingestion time: { $tend - $tstart }";

# Clean data
@dsTS = @dsTS.grep({ $_<Close> ~~ Numeric });

# Summary
records-summary(@dsTS, field-names => <DateTime Close>);

# Deduce type
say deduce-type(@dsTS);

# Plot
say text-list-plot(@dsTS.map({ $_<DateTime>.Numeric }).List, @dsTS.map(*<Close>).List, width => 120, height => 20);