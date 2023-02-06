# Data::Cryptocurrencies Raku package

Raku package of cryptocurrency data retrieval.

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

my @ts = cryptocurrency-data('BTC', dates => (DateTime.new(2020,1,1,0,0,0), now), props => <DateTime Close>, format => 'timeseries'):!cache-all;

say @ts.elems;
```

When we request the data to be returned as "timeseries" the result is an array of pairs (sorted by date.)
Here are BTC values for the last week (at the point of retrieval):

```perl6
.say for @ts.tail(7)
```

Here is a summary:

```perl6
records-summary(@ts.map({ %(Key => $_.key, Value => $_.value) }), field-names => <Key Value>);
```

```perl6
say text-list-plot(@ts>>.key>>.DateTime>>.Numeric, @ts>>.value.Array, width => 160, height => 20);
```

-------

## CLI

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

