xquery version '3.1';
(:~
This module contains XQSuite tests for library
http://markup.nz/#csv
:)
module namespace t-csv = "http://markup.nz/#t-csv";
import module namespace csv = "http://markup.nz/#csv";
import module namespace test = "http://exist-db.org/xquery/xqsuite"
  at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";


declare
%test:setUp
function t-csv:setUp(){
 (: util:log-system-out('INFO: test setup') :)
  ()
};

declare
%test:tearDown
function t-csv:tearDown(){
 (: util:log-system-out('INFO: test teardown') :)
 ()
};


(:~
test for csv:conditions
:)
declare
%test:name("map should contain all required items")
%test:assertTrue
function t-csv:conditions(){
  map { 
    'href' : '/db/unit-tests/fixtures/2018-12.csv', 
    'header-line': 6,
    'record-start': 8,
    'separator': ','
    } =>
  csv:conditions()
};

(:~
test for csv:lines 
:)
declare
%test:name("should return lines from csv doc")
%test:assertXPath("$result => count() gt 0")
function t-csv:lines(){
  map { 
    'href' : '/db/unit-tests/fixtures/2018-12.csv', 
    'header-line': 6,
    'record-start': 8,
    'separator': ','
    } =>
  csv:lines()
};

(:~
test for csv:mapFields
:)
declare
%test:name("should create map of a field position for record")
%test:assertXPath('$result("date") eq 1')
function t-csv:mapFields(){
 let $map :=  map { 
    'href' : '/db/unit-tests/fixtures/2018-12.csv', 
    'header-line': 6,
    'record-start': 8,
    'separator': ','
    }
  return 
  $map =>
  csv:lines() =>
  csv:mapFields($map)
};

declare
%test:name("should convert line array into array of arrays")
%test:assertXPath('$result instance of array(*) ')
%test:assertXPath('$result => array:size() gt 0' )
function t-csv:toArray(){
 let $map :=  map { 
    'href' : '/db/unit-tests/fixtures/2018-12.csv', 
    'header-line': 6,
    'record-start': 8,
    'separator': ','
    }

 return (
  $map =>
  csv:lines() => 
  csv:toArray($map)
)
};

declare
%test:name('first record is an array')
%test:assertXPath('$result instance of array(*)')
%test:assertXPath('$result => array:size() gt 0' )
function t-csv:firstRecord(){
 let $map := map { 
    'href' : '/db/unit-tests/fixtures/2018-12.csv', 
    'header-line': 6,
    'record-start': 8,
    'separator': ','
    }
 let $lines :=  $map => csv:lines()
 let $field := $lines => csv:mapFields($map)
 let $records := $lines => csv:toArray($map)
 return 
 array:head($records)
};

declare
%test:name('last record is an array')
%test:assertXPath('$result instance of array(*)')
%test:assertXPath('$result => array:size() gt 0' )
function t-csv:lastRecord(){
 let $map := map { 
    'href' : '/db/unit-tests/fixtures/2018-12.csv', 
    'header-line': 6,
    'record-start': 8,
    'separator': ','
    }
 let $lines :=  $map => csv:lines()
 let $field := $lines => csv:mapFields($map)
 let $records := $lines => csv:toArray($map)
 return
 array:tail($records)
};

declare
%test:name('can get a record item using field mapped headers')
%test:assertXPath('$result instance of xs:string')
%test:assertXPath('$result => string-length() gt 0' )
function t-csv:field(){
 let $map := map { 
    'href' : '/db/unit-tests/fixtures/2018-12.csv', 
    'header-line': 6,
    'record-start': 8,
    'separator': ','
    }
 let $lines :=  $map => csv:lines()
 let $field := $lines => csv:mapFields($map)
 let $records := $lines => csv:toArray($map)
 let $record := array:head($records)
 return 
  $record?($field('date'))
};
