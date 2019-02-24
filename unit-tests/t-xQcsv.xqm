xquery version '3.1';
(:~
This module contains XQSuite tests for library
http://markup.nz/#xQcsv
:)
module namespace t-xQcsv = "http://markup.nz/#t-xQcsv";
import module namespace xQcsv = "http://markup.nz/#xQcsv";
import module namespace test = "http://exist-db.org/xquery/xqsuite"
  at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

(:~
xQcsv:example
@given arg 'Grant' as xs:string
@when function example function is called
@then 'Hi Grant' is the correct response
:)
declare
%test:name(
"
should say 'Hi Grant"
)
%test:args('Grant')
%test:assertEquals('Hi Grant')
function t-xQcsv:example($arg){
$arg => xQcsv:example()
};
