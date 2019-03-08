# yet another CSV xQuery Library module

The <b>csv</b> xQuery library provides functions turn a CSV file into an array of
arrays. You can visualise the array of arrays as being like a spreadsheet.
We have multiple records where each record is in a row and each record contains fields in field column.


## Use Case

I intend to use this library for handling downloaded CSV financial statements. 

## Convenience Functions

The lib provides a simple mapping of the CSV header line to the fields index integer
So if we have a header named 'amount' we can 'sum' the amount field column.
e.g.

```
 let $field := $lines => csv:mapFields($map)
 let $records := $lines => csv:toArray($map)
 let $sumAmount := string(sum( $records?*?($field('amount')) ! number(.)))
```

The library also provides some formating alignment functions so when rendering on a terminal all the field columns will be lined up.

[![asciicast](https://asciinema.org/a/232385.svg)](https://asciinema.org/a/232385)





<!-- One Paragraph of project description goes here -->

<!--
[![Build Status](https://travis-ci.org/grantmacken/csv.svg?branch=master)](https://travis-ci.org/grantmacken/oAuth1)
[![GitHub release](https://img.shields.io/github/release/grantmacken/csv/all.svg)](https://gitHub.com/grantmacken/csv/releases/latest)
-->
<!--
# Using This Library

# Example

# Deployment


TODO!

## Built With

* [eXistdb docker image]() - xQuery engine and database

## Versioning

We use [SemVer](http://semver.org/) for versioning. 

[latest release on this repo](https://github.com/grantmacken/csv/releases/latest
-->
<!--
[![GitHub tag](https://img.shields.io/github/tag/grantmacken/csv.svg)](https://gitHub.com/grantmacken/csv/tags/)
-->

<!--
## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426).
-->
<!--
# TESTS

cast of running tests

Link to travis build
-->
