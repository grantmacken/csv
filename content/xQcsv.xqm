xquery version "3.1";
module namespace xQcsv  = "http://markup.nz/#xQcsv";
(:~
: The <b>xQcsv</b> library provides functions ...
:)

(:~
show what xQcsv lib can do in example
:)
declare function xQcsv:example($name) as xs:string*{
(( 'Hi', $name )) => string-join(' ')
};
