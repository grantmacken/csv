xquery version "3.1";

(:~
: The <b>csv</b> library provides functions turn 
: a csv file into an array of arrays
: 
:  You can visualise the array of arrays as being like a spreadsheet
:  each record (row) containing fields (column cells) and
:  like a spreadsheet we can mathematicaly calculate (sum, average etc)
:  a column  
:  
: 
: @author Grant Mackenzie
: @version v0.0.1
: @since 2019-03-07
: @see https://github.com/grantmacken/csv
:)
module namespace csv  = "http://markup.nz/#csv";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare variable $csv:noKey := QName( 'http://markup.nz/#csv','noKey');
declare variable $csv:noText := QName( 'http://markup.nz/#csv','noText');

(:~
: show what csv lib can do in example
:)
declare function csv:example(){
 let $nl := "&#10;"
 let $map := map { 
    'href' : '/db/unit-tests/fixtures/2018-12.csv', 
    'header-line': 6,
    'record-start': 8,
    'separator': ','
    }
 let $conditions := $map => csv:conditions()
 let $lines :=  $map => csv:lines()
 let $field := $lines => csv:mapFields($map)
 let $records := $lines => csv:toArray($map)
 let $width := $records => csv:colWidth($field) 
 let $sumAmount := string(sum( $records?*?($field('amount')) ! number(.)))
return ( 
for $record in $records?*
  let $date :=   csv:pad($record?($field('date')), $width('date') )
  let $payee  := csv:pad($record?($field('payee')), $width('payee') )
  let $amount := csv:pad($record?($field('amount')), $width('amount') )
  return (
  string-join(($date,$payee,$amount,$nl),'&#9;')
  ),$nl,
   string-join(
   (
   string-join((for $i in 1 to $width('date') return ' '),''),
   string-join((for $i in 1 to $width('payee') return ' '),''),
   $sumAmount
   ),'&#9;'), 
$nl
)};


(:~
: trim removes any whitespace at start and end of a field
: @param $field the field in a record to be trimmed
:)
declare 
function csv:trim( $field as xs:string ) as xs:string {
 if ( matches($field ,'(^\s+)|(\s+$)') )  
 then ( replace( $field, '(^\s+)|(\s+$)', '') )
 else ( $field )
};

(:~
: trim removes any quotes at start and end of a field
: @param $field the field in a record to be dequoted
:)
declare 
function csv:dequote( $field as xs:string ) as xs:string {
 if ( matches($field ,"[&quot;'](.*)[&quot;']$") )  
 then ( replace( $field, "[&quot;'](.*)[&quot;']$", '$1') )
 else ( $field )
};

(:~
: if match found turn date into iso date
: @param $field the field in a record to be iso dated
:)
declare 
function csv:isoDate( $field as xs:string ) as xs:string {
 if ( matches($field ,'^(\d{4}/\d{2}/\d{2})$' ) )  
 then ( translate( $field, '/', '-') )
 else ( $field )
};

(:~
: left pad a field so field collumns have a consisten width
: @param $field the text in field to be padded
:)
declare 
function csv:pad( $str as xs:string, $length as xs:integer) as xs:string {
( for $i in (1 to $length - string-length($str)) 
  return ' ' ) => 
  string-join('')  || $str
};


(:~
: make sure properties map contains right keys
: @param $map the key properties required 
:)
declare 
function csv:conditions( $map as map(*) ) as xs:boolean {
(
  if ( map:contains($map, 'href' ) ) then (
    if ( not( map:contains($map, 'record-start' )) ) 
       then ( error( $csv:noKey , 'map has no record-start key' )) 
    else if (not( map:contains($map, 'header-line' ))  )
        then ( error( $csv:noKey , 'map has no header-line key' ))
    else if (not( map:contains($map, 'separator' ))  )
        then ( error( $csv:noKey , 'map has no separator key' ))
     else ()
    )
  else (error( $csv:noKey , 'map has no href key' ) ),
   if ( unparsed-text-available($map('href')) ) then () 
   else (error( $csv:noText , 'no csv file available' )),
  true()
)};

(:~
: get the lines contained in the csv file
: @param $map  the csv properties map contains 'href' key  
: @return a sequence of lines 
:)
declare 
function csv:lines( $map as map(*) ) as item()+ {
$map('href') => 
unparsed-text-lines()
};

(:~
: map containing header field names as keys,
: where key value is a record index integer
: @param $lines as extracted by calling csv:mapFields
: @param $map  the csv properties map contains 'header-line' key  
: @return $map  a conveniance field key to index mapping 
:)
declare 
function csv:mapFields( $lines as item()+,  $map as map(*) ) as map(*) {
map:new (
 for $item at $int in $lines =>
              subsequence( xs:integer($map('header-line')),1) =>
              tokenize($map('separator')) => 
              for-each( function($token){
                 $token => 
                  translate(' ' ,'-') =>
                  lower-case()
               })
 return ( map:entry($item,$int))
 )
};

(:~
convert line array into array of arrays
: @param $lines as extracted by calling csv:mapFields
: @param $map  the csv properties map contains 'record-start' key  
: @return array of arrays 
:)
declare 
function csv:toArray( $lines as item()+, $map as map(*) ) as array(*) {
 array {
 $lines =>
 subsequence( xs:integer($map('record-start'))) =>
  for-each(
    function($record){
        array {
           $record => 
           tokenize($map('separator')) => 
            for-each( function($field){
              let $deQuoted := csv:dequote($field)
              let $trimmed := csv:trim($deQuoted)
              let $dated := csv:isoDate($trimmed)
              return
              $dated
             })
        }
       }
   )
 }
};

(:~
: establish a map of field column sizes for screen rendering
: @param $records the array of array extracted from the csv file
: @param $field   map containing field names as keys, where key value is a record index integer
: @return a map of each field column width size used when padding a text field
:)
declare 
function csv:colWidth( $records as array(*),  $field as map(*) ) as map(*) {
map:new(
   for $key in ( map:keys($field) )
   let $width := max( $records?*?($field($key)) ! string-length(.))
   return ( map:entry($key,$width))
   )
};
