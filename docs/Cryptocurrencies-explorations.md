# Cryptocurrencies explorations

## Introduction

The main goal of this computational Markdown document is to provide some basic views and insights into the landscape of cryptocurrencies. 
The “landscape” we consider consists of price action and trading volume time series for cryptocurrencies found in Yahoo Finance.

In this document we compute and plot with Raku the statistics in [AA1].

### Details on "running" the document

The Raku package used for data retrieval is "Data::Cryptocurrencies", [AAp1].
The JavaScript D3 plots are made via "JavaScript::D3", [AAp2].

This Markdown document is converted to its woven Markdown version with "Text::CodeProcessing", [AAp3].
The woven Markdown document is converted to an HTML document with "Markdown::Grammar", [AAp4].

Here is the corresponding shell command:

```
file-code-chunks-eval Cryptocurrencies-explorations.md && 
  from-markdown Cryptocurrencies-explorations_woven.md -t html -o Cryptocurrencies-explorations.html && 
  open Cryptocurrencies-explorations.html
```

-------

## Setup

Here we load the packages used below:

```perl6
use Data::Cryptocurrencies;
use Data::Reshapers;
use Data::Summarizers;
use Text::Plot;
use JavaScript::D3;
```

-------

## Time series

Here we get Bitcoin (BTC) data from 1/1/2020 until now:

```perl6
my %ccTS = cryptocurrency-data(<BTC ETH>, dates => (DateTime.new(2020,1,1,0,0,0), now), props => <DateTime Close>, format => 'hash'):cache-all;

say %ccTS.elems;
```

Here is a summary:

```perl6
records-summary(%ccTS);
```

Here are D3.js plots:

```perl6
my %ts4 = %ccTS.map({ $_.key => $_.value.map(-> %r { %( date => %r<DateTime>.Str.substr(0,10), value => %r<Close>.Numeric, group => $_.key ) }).grep({ $_.<value> ~~ Numeric }) });
say %ts4>>.elems;
```

```perl6
deduce-type(%ts4<BTC>)
```

```perl6, results=asis
js-d3-date-list-plot(%ts4<BTC>, plot-label => 'BTC', width => 800, height => 400, format => 'html', div-id => 'BTC');
```


```perl6, results=asis
js-d3-date-list-plot(%ts4<ETH>, plot-label => 'ETH', width => 800, height => 400, format => 'html', div-id => 'ETH');
```

-------

## Pareto principle adherence

Get data for all cryptocurrencies:

```perl6
my @dsData = cryptocurrency-data('all', dates => (now - 14 * 24 * 3600, now), props => <Symbol DateTime Close Volume>, format => 'dataset');
say "Dimensions : {dimensions(@dsData)}.";
```

Clean data and show summary:

```perl6
@dsData = @dsData.grep({ $_<Close> ~~ Numeric });
#records-summary(@dsData);
```

Group by "Symbol" and find price- and volume totals per group:

```perl6
my %groups = group-by(@dsData, "Symbol");

my %prices = %groups.map({ $_.key => $_.value.map(*<Close>).sum });
my %volumes = %groups.map({ $_.key => $_.value.map(*<Volume>).sum });

say %volumes.sort({ -$_.value }).head(5);
```

```
say text-pareto-principle-plot(%prices.values.List, title => 'Prices');
say text-pareto-principle-plot(%volumes.values.List, title => 'Volumes');
```

Here is the Pareto plot for closing prices:

```perl6, results=asis
js-d3-list-plot(pareto-principle-statistic(%prices)>>.value, 
                plot-label => 'Pareto principle adherence for closing prices', 
                width => 400, height => 300, 
                format => 'html', div-id => 'pareto-prices'):grid-lines;
```

Here is the Pareto plot for trading volumes:

```perl6, results=asis
js-d3-list-plot(pareto-principle-statistic(%volumes)>>.value, 
                plot-label => 'Pareto principle adherence for trading volumes',
                width => 400, height => 300, 
                format => 'html', div-id => 'pareto-volumes'):grid-lines;
```

-------

## References

### Articles

[AA1] Anton Antonov
["Crypto-currencies data acquisition with visualization"](https://mathematicaforprediction.wordpress.com/2021/06/19/crypto-currencies-data-acquisition-with-visualization/),
(2021),
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

[AA2] Anton Antonov
["Cryptocurrencies data explorations"](https://mathematicaforprediction.wordpress.com/2021/06/22/cryptocurrencies-data-explorations/),
(2021),
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).


### Functions, packages

[AAf1] Anton Antonov,
[CryptocurrencyData](https://www.wolframcloud.com/obj/antononcube/DeployedResources/Function/CryptocurrencyData/) Mathematica resource function,
(2021).
[WolframCloud/antononcube](https://www.wolframcloud.com/obj/antononcube).

[AAp1] Anton Antonov,
[Data::Cryptocurrencies Raku package](https://github.com/antononcube/Raku-Data-Cryptocurrencies),
(2023).
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[JavaScript::D3 Raku package](https://github.com/antononcube/Raku-JavaScript-D3),
(2022).
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[Text::CodeProcessing Raku package](https://github.com/antononcube/Raku-Text-CodeProcessing),
(2021).
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[Markdown::Grammar](https://github.com/antononcube/Raku-Markdown-Grammar),
(2022).
[GitHub/antononcube](https://github.com/antononcube).

