# Data::Cryptocurrencies Raku package

This Raku package has functions for cryptocurrency data retrieval.
(At this point, only [Yahoo Finance](https://finance.yahoo.com/crypto/) is used as a data source.)

The implementation follows the Mathematica implementation in [AAf1] described in [AA1].
(Further explorations are discussed in [AA2].)

-------

## Installation

From [Zef ecosystem](https://raku.land):

```
zef install Data::Cryptocurrencies
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-Data-Cryptocurrencies.git
```

-------

## Usage examples

Here we get Bitcoin (BTC) data from 1/1/2020 until now:

```perl6
use Data::Cryptocurrencies;
use Data::Summarizers;
use Text::Plot;

my @ts = cryptocurrency-data('BTC', dates => (DateTime.new(2020, 1, 1, 0, 0, 0), now), props => <DateTime Close>,
        format => 'dataset'):!cache-all;

say @ts.elems;
```

When we request the data to be returned as “dataset” then the result is an array of hashes.
When we request the data to be returned as "timeseries" the result is an array of pairs (sorted by date.)
Here are BTC values for the last week (at the point of retrieval):

```perl6
.say for @ts.tail(7)
```

Here is a summary:

```perl6
records-summary(@ts, field-names => <DateTime Close>);
```

Clean data:

```perl6
@ts = @ts.grep({ $_<Close> ~~ Numeric }).Array;
say @ts.elems;
```

Here is a text-based plot of the corresponding time series:

```perl6
say text-list-plot(@ts.map(*<DateTime>.Instant.Int).List, @ts.map(*<Close>).List, width => 100, height => 20);
```

-------

## Data caching

Since the downloading of the cryptocurrencies data can be time consuming ( close to 1 minute)
it is a good idea to do data caching.

Data caching is "triggered" with the adverb `:cache-all`. Here is an example:

```perl6
cryptocurrency-data('BTC', dates => 'today'):cache-all;
```

By default no data caching is done (i.e. `:!cache-all`.)
The data is stored in the `$XDG_DATA_HOME` directory. See [JS1]. Every day new data is obtained.

**Remark:** The use of cached data greatly speeds up the cryptocurrencies explorations with this package.

-------

## CLI

The package provides a Command Line Interface (CLI) script. Here is its usage message:

```shell
cryptocurrency-data --help
```

-------

## Additional usage examples

The notebook
["Cryptocurrency-explorations.ipynb"](./docs/Cryptocurrencies-explorations.ipynb)
provides additional usage examples using [D3.js](https://d3js.org) plots.
(It loosely follows [AA2].)

-------

## References

### Articles

[AA1] Anton Antonov
["Crypto-currencies data acquisition with visualization"](https://mathematicaforprediction.wordpress.com/2021/06/19/crypto-currencies-data-acquisition-with-visualization/)
,
(2021),
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

[AA2] Anton Antonov
["Cryptocurrencies data explorations"](https://mathematicaforprediction.wordpress.com/2021/06/22/cryptocurrencies-data-explorations/)
,
(2021),
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

### Functions, packages

[AAf1] Anton Antonov,
[CryptocurrencyData](https://www.wolframcloud.com/obj/antononcube/DeployedResources/Function/CryptocurrencyData/)
Mathematica resource function,
(2021),
[WolframCloud/antononcube](https://www.wolframcloud.com/obj/antononcube).

[AAp1] Anton Antonov,
[Data::Summarizers Raku package](https://github.com/antononcube/Raku-Data-Summarizers),
(2021-2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[Text::Plot Raku package](https://github.com/antononcube/Raku-Text-Plot),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[JS1] Jonathan Stowe,
[XDG::BaseDirectory Raku package](https://raku.land/zef:jonathanstowe/XDG::BaseDirectory),
(2016-2023),
[Zef-ecosystem/jonathanstowe](https://raku.land/zef:jonathanstowe).