# Data::Cryptocurrencies Raku package

This Raku package has functions for cryptocurrency data retrieval.
(At this point, only Yahoo Finance is used as a data source.)

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
```
# 1137
```

When we request the data to be returned as "timeseries" the result is an array of pairs (sorted by date.)
Here are BTC values for the last week (at the point of retrieval):

```perl6
.say for @ts.tail(7)
```
```
# {Close => 23331.847656, DateTime => 2023-02-04T00:00:00Z}
# {Close => 22955.666016, DateTime => 2023-02-05T00:00:00Z}
# {Close => 22760.109375, DateTime => 2023-02-06T00:00:00Z}
# {Close => 23264.291016, DateTime => 2023-02-07T00:00:00Z}
# {Close => 22939.398438, DateTime => 2023-02-08T00:00:00Z}
# {Close => null, DateTime => 2023-02-09T00:00:00Z}
# {Close => 21863.925781, DateTime => 2023-02-10T00:00:00Z}
```

Here is a summary:

```perl6
records-summary(@ts, field-names => <DateTime Close>);
```
```
# +--------------------------------+----------------------+
# | DateTime                       | Close                |
# +--------------------------------+----------------------+
# | Min    => 2020-01-01T00:00:37Z | 8755.246094  => 1    |
# | 1st-Qu => 2020-10-10T12:00:37Z | 45585.03125  => 1    |
# | Mean   => 2021-07-22T00:00:37Z | 55888.132813 => 1    |
# | Median => 2021-07-22T00:00:37Z | 29098.910156 => 1    |
# | 3rd-Qu => 2022-05-02T12:00:37Z | 20471.482422 => 1    |
# | Max    => 2023-02-10T00:00:37Z | 21395.019531 => 1    |
# |                                | 53555.109375 => 1    |
# |                                | (Other)      => 1130 |
# +--------------------------------+----------------------+
```

Clean data:

```perl6
@ts = @ts.grep({ $_<Close> ~~ Numeric }).Array;
say @ts.elems;
```
```
# 1136
```

```perl6
say text-list-plot(@ts.map(*<DateTime>.Instant.Int).List, @ts.map(*<Close>).List, width => 100, height => 20);
```
```
# +------+-----------------+-----------------+-----------------+-----------------+-----------------+-+          
# +                                                                                                  +  70000.00
# |                                                       * *                                        |          
# |                                      *  *             ***                                        |          
# +                                     *******           *****                                      +  60000.00
# |                                     *******        * **  **                                      |          
# +                                    **** ***       ** *    ***                                    +  50000.00
# |                                    **     *      *****    ***  *   *                             |          
# |                                 *         **    **  **      ** *******                           |          
# +                                 ****      ****  *             ***** ***                          +  40000.00
# |                                 ***        ******             *       *                          |          
# +                                 ***          * *                      ***                        +  30000.00
# |                                **                                        *   *                   |          
# |                                *                                         ********* **    ***     |          
# +                             ***                                          ***  ************       +  20000.00
# |                      *    ***                                                       **           |          
# +     ******   **************                                                                      +  10000.00
# |    **    *****                                                                                   |          
# +                                                                                                  +      0.00
# +------+-----------------+-----------------+-----------------+-----------------+-----------------+-+          
#        1580000000.00     1600000000.00     1620000000.00     1640000000.00     1660000000.00     1680000000.00
```

-------

## Data caching

Since the downloading of the cryptocurrencies data can be time consuming ( close to 1 minute)
it is a good idea to do data caching.

Data caching is "triggered" with the adverb `:cache-all`. Here is an example:

```perl6
cryptocurrency-data('BTC', dates => 'today'):cache-all;
```
```
# [{Close => 457.334015, DateTime => 2014-09-17T00:00:00Z} {Close => 424.440002, DateTime => 2014-09-18T00:00:00Z} {Close => 394.79599, DateTime => 2014-09-19T00:00:00Z} {Close => 408.903992, DateTime => 2014-09-20T00:00:00Z} {Close => 398.821014, DateTime => 2014-09-21T00:00:00Z} {Close => 402.152008, DateTime => 2014-09-22T00:00:00Z} {Close => 435.790985, DateTime => 2014-09-23T00:00:00Z} {Close => 423.204987, DateTime => 2014-09-24T00:00:00Z} {Close => 411.574005, DateTime => 2014-09-25T00:00:00Z} {Close => 404.424988, DateTime => 2014-09-26T00:00:00Z} {Close => 399.519989, DateTime => 2014-09-27T00:00:00Z} {Close => 377.181, DateTime => 2014-09-28T00:00:00Z} {Close => 375.46701, DateTime => 2014-09-29T00:00:00Z} {Close => 386.944, DateTime => 2014-09-30T00:00:00Z} {Close => 383.61499, DateTime => 2014-10-01T00:00:00Z} {Close => 375.071991, DateTime => 2014-10-02T00:00:00Z} {Close => 359.511993, DateTime => 2014-10-03T00:00:00Z} {Close => 328.865997, DateTime => 2014-10-04T00:00:00Z} {Close => 320.51001, DateTime => 2014-10-05T00:00:00Z} {Close => 330.07901, DateTime => 2014-10-06T00:00:00Z} {Close => 336.187012, DateTime => 2014-10-07T00:00:00Z} {Close => 352.940002, DateTime => 2014-10-08T00:00:00Z} {Close => 365.026001, DateTime => 2014-10-09T00:00:00Z} {Close => 361.562012, DateTime => 2014-10-10T00:00:00Z} {Close => 362.299011, DateTime => 2014-10-11T00:00:00Z} {Close => 378.549011, DateTime => 2014-10-12T00:00:00Z} {Close => 390.414001, DateTime => 2014-10-13T00:00:00Z} {Close => 400.869995, DateTime => 2014-10-14T00:00:00Z} {Close => 394.77301, DateTime => 2014-10-15T00:00:00Z} {Close => 382.556, DateTime => 2014-10-16T00:00:00Z} {Close => 383.757996, DateTime => 2014-10-17T00:00:00Z} {Close => 391.441986, DateTime => 2014-10-18T00:00:00Z} {Close => 389.54599, DateTime => 2014-10-19T00:00:00Z} {Close => 382.845001, DateTime => 2014-10-20T00:00:00Z} {Close => 386.475006, DateTime => 2014-10-21T00:00:00Z} {Close => 383.15799, DateTime => 2014-10-22T00:00:00Z} {Close => 358.416992, DateTime => 2014-10-23T00:00:00Z} {Close => 358.345001, DateTime => 2014-10-24T00:00:00Z} {Close => 347.270996, DateTime => 2014-10-25T00:00:00Z} {Close => 354.70401, DateTime => 2014-10-26T00:00:00Z} {Close => 352.989014, DateTime => 2014-10-27T00:00:00Z} {Close => 357.618011, DateTime => 2014-10-28T00:00:00Z} {Close => 335.591003, DateTime => 2014-10-29T00:00:00Z} {Close => 345.304993, DateTime => 2014-10-30T00:00:00Z} {Close => 338.321014, DateTime => 2014-10-31T00:00:00Z} {Close => 325.748993, DateTime => 2014-11-01T00:00:00Z} {Close => 325.891998, DateTime => 2014-11-02T00:00:00Z} {Close => 327.553986, DateTime => 2014-11-03T00:00:00Z} {Close => 330.492004, DateTime => 2014-11-04T00:00:00Z} {Close => 339.485992, DateTime => 2014-11-05T00:00:00Z} {Close => 349.290009, DateTime => 2014-11-06T00:00:00Z} {Close => 342.415009, DateTime => 2014-11-07T00:00:00Z} {Close => 345.488007, DateTime => 2014-11-08T00:00:00Z} {Close => 363.264008, DateTime => 2014-11-09T00:00:00Z} {Close => 366.924011, DateTime => 2014-11-10T00:00:00Z} {Close => 367.695007, DateTime => 2014-11-11T00:00:00Z} {Close => 423.561005, DateTime => 2014-11-12T00:00:00Z} {Close => 420.734985, DateTime => 2014-11-13T00:00:00Z} {Close => 397.817993, DateTime => 2014-11-14T00:00:00Z} {Close => 376.132996, DateTime => 2014-11-15T00:00:00Z} {Close => 387.881989, DateTime => 2014-11-16T00:00:00Z} {Close => 387.40799, DateTime => 2014-11-17T00:00:00Z} {Close => 375.197998, DateTime => 2014-11-18T00:00:00Z} {Close => 380.554993, DateTime => 2014-11-19T00:00:00Z} {Close => 357.839996, DateTime => 2014-11-20T00:00:00Z} {Close => 350.847992, DateTime => 2014-11-21T00:00:00Z} {Close => 352.920013, DateTime => 2014-11-22T00:00:00Z} {Close => 367.572998, DateTime => 2014-11-23T00:00:00Z} {Close => 376.901001, DateTime => 2014-11-24T00:00:00Z} {Close => 375.347992, DateTime => 2014-11-25T00:00:00Z} {Close => 368.369995, DateTime => 2014-11-26T00:00:00Z} {Close => 369.670013, DateTime => 2014-11-27T00:00:00Z} {Close => 376.446991, DateTime => 2014-11-28T00:00:00Z} {Close => 375.490997, DateTime => 2014-11-29T00:00:00Z} {Close => 378.046997, DateTime => 2014-11-30T00:00:00Z} {Close => 379.244995, DateTime => 2014-12-01T00:00:00Z} {Close => 381.315002, DateTime => 2014-12-02T00:00:00Z} {Close => 375.01001, DateTime => 2014-12-03T00:00:00Z} {Close => 369.604004, DateTime => 2014-12-04T00:00:00Z} {Close => 376.854004, DateTime => 2014-12-05T00:00:00Z} {Close => 374.785004, DateTime => 2014-12-06T00:00:00Z} {Close => 375.095001, DateTime => 2014-12-07T00:00:00Z} {Close => 361.908997, DateTime => 2014-12-08T00:00:00Z} {Close => 352.218994, DateTime => 2014-12-09T00:00:00Z} {Close => 346.36499, DateTime => 2014-12-10T00:00:00Z} {Close => 350.506012, DateTime => 2014-12-11T00:00:00Z} {Close => 352.541992, DateTime => 2014-12-12T00:00:00Z} {Close => 347.376007, DateTime => 2014-12-13T00:00:00Z} {Close => 351.631989, DateTime => 2014-12-14T00:00:00Z} {Close => 345.345001, DateTime => 2014-12-15T00:00:00Z} {Close => 327.062012, DateTime => 2014-12-16T00:00:00Z} {Close => 319.776001, DateTime => 2014-12-17T00:00:00Z} {Close => 311.395996, DateTime => 2014-12-18T00:00:00Z} {Close => 317.842987, DateTime => 2014-12-19T00:00:00Z} {Close => 329.955994, DateTime => 2014-12-20T00:00:00Z} {Close => 320.842987, DateTime => 2014-12-21T00:00:00Z} {Close => 331.885986, DateTime => 2014-12-22T00:00:00Z} {Close => 334.571991, DateTime => 2014-12-23T00:00:00Z} {Close => 322.533997, DateTime => 2014-12-24T00:00:00Z} {Close => 319.007996, DateTime => 2014-12-25T00:00:00Z} ...]
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
```
# Usage:
#   cryptocurrency-data [<symbol>] [-p|--properties=<Str>] [--start-date=<Str>] [--end-date=<Str>] [-c|--currency=<Str>] [--format=<Str>] -- Retrieves cryptocurrency data.
#   
#     [<symbol>]               Cryptocurrency symbol. [default: 'BTC']
#     -p|--properties=<Str>    Properties to retrieve. [default: 'all']
#     --start-date=<Str>       Start date. [default: 'auto']
#     --end-date=<Str>         End date. [default: 'now']
#     -c|--currency=<Str>      Currency. [default: 'USD']
#     --format=<Str>           Format of the result [default: 'json']
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