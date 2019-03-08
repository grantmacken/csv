# yet another CSV xQuery Library module

The <b>csv</b> xQuery library provides functions turn a CSV file into an array of
arrays. You can visualise the array of arrays as being like a spreadsheet.
We have multiple records where each record is in a row and each record contains fields in field column.


## Use Case

I intend to use this library for handling downloaded CSV financial statements. 

## Basics

The start basis is some CSV properties, 
in the form of a key-value map. 
The can use this map to create an array of arrays

```
 let $map := map { 
    'href' : '/db/unit-tests/fixtures/2018-12.csv', 
    'header-line': 6,
    'record-start': 8,
    'separator': ','
    } 
 return
 $map => csv:lines() => csv:toArray($map)
```


## Convenience Functions

The lib provides a simple mapping of the CSV header line to the fields index integer
So if we have a header named 'amount' we can 'sum' the amount field column.
e.g.

```
 let $lines :=  $map => csv:lines()
 let $field := $lines => csv:mapFields($map)
 let $records := $lines => csv:toArray($map)
 let $sumAmount := string(sum( $records?*?($field('amount')) ! number(.)))
```

The library also provides some formating alignment functions so when rendering on a terminal all the field columns will be lined up.

```
let $lines :=  $map => csv:lines()
let $field := $lines => csv:mapFields($map)
let $records := $lines => csv:toArray($map)
let $width := $records => csv:colWidth($field) 
return ( 
for $record in $records?*
  let $date :=   csv:pad($record?($field('date')), $width('date') )
  let $payee  := csv:pad($record?($field('payee')), $width('payee') )
  let $amount := csv:pad($record?($field('amount')), $width('amount') )
  return (
  string-join(($date,$payee,$amount,$nl),'&#9;')
  )
```

The following asciicast showcases the above mentioned field column alignment and 
performing a sum calculation on the field column. 
The CSV data comes from a downloaded monthly statement and is found in the unit-tests/fixtures folder 

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
