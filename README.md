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
```
# 1133
```

When we request the data to be returned as "timeseries" the result is an array of pairs (sorted by date.)
Here are BTC values for the last week (at the point of retrieval):

```perl6
.say for @ts.tail(7)
```
```
# 2023-01-31T00:00:00Z => 23139.283203
# 2023-02-01T00:00:00Z => 23723.769531
# 2023-02-02T00:00:00Z => 23471.871094
# 2023-02-03T00:00:00Z => 23449.322266
# 2023-02-04T00:00:00Z => 23331.847656
# 2023-02-05T00:00:00Z => 22955.666016
# 2023-02-06T00:00:00Z => 22912.414063
```

Here is a summary:

```perl6
records-summary(@ts.map({ %(Key => $_.key, Value => $_.value) }), field-names => <Key Value>);
```
```
# +------------------------------+-----------------------------+
# | Key                          | Value                       |
# +------------------------------+-----------------------------+
# | 2020-07-14T00:00:00Z => 1    | Min    => 4970.788086       |
# | 2021-12-31T00:00:00Z => 1    | 1st-Qu => 11771.7333985     |
# | 2021-08-19T00:00:00Z => 1    | Mean   => 28634.48539127714 |
# | 2022-11-24T00:00:00Z => 1    | Median => 23139.283203      |
# | 2022-06-21T00:00:00Z => 1    | 3rd-Qu => 42519.353516      |
# | 2021-11-17T00:00:00Z => 1    | Max    => 67566.828125      |
# | 2020-08-21T00:00:00Z => 1    |                             |
# | (Other)              => 1126 |                             |
# +------------------------------+-----------------------------+
```

```perl6
say text-list-plot(@ts>>.key>>.DateTime>>.Numeric, @ts>>.value.Array, width => 160, height => 20);
```
```
# +----------+----------------------------+-----------------------------+----------------------------+----------------------------+----------------------------+-+          
# +                                                                                                                                                              +  70000.00
# |                                                                                          * **                                                                |          
# |                                                              *   *                      *****                                                                |          
# +                                                            * ***** ***                  *** ***                                                              +  60000.00
# |                                                           ** **** ***              *   **    **                                                              |          
# +                                                           ***  *  ** *           ***   *       ***                                                           +  50000.00
# |                                                          ****        *          ****** *       ****     *    **                                              |          
# |                                                      *               **        **    **            ** ***********                                            |          
# +                                                      ** **            ****    **                     ** ****   ****                                          +  40000.00
# |                                                     *****             *********                      *            *                                          |          
# +                                                     ** *                  *  *                                    *****                                      +  30000.00
# |                                                    **                                                                 *       *                              |          
# |                                                   **                                                                   ************* *  **        ****       |          
# +                                               *****                                                                    ****     ******** **********          +  20000.00
# |                                    *       ****                                                                                          * *                 |          
# +        *********     ***********************                                                                                                                 +  10000.00
# |       **       *******                                                                                                                                       |          
# +                                                                                                                                                              +      0.00
# +----------+----------------------------+-----------------------------+----------------------------+----------------------------+----------------------------+-+          
#            1580000000.00                1600000000.00                 1620000000.00                1640000000.00                1660000000.00                1680000000.00
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

