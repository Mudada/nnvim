def lists-to-record [header: list]: list -> record {
  let values = $in

  $header | enumerate | par-each { |v|
    {($v.item): ($values | get -i $v.index)}
  } | reduce {|it, acc| $acc | merge $it }
}

def behead []: list<list> -> table {
  let header = $in | get 0
  let body = $in | skip

  $body | par-each { |v| 
    $v | lists-to-record $header
  } 
}

let test = [[a b c] [1 2 3] [4 5 6]]
let testResult = [[a b c]; [1 2 3] [4 5 6]]

let smallHead = [[a b] [1 2 3] [4 5 6]]
let smallHeadResult = [[a b]; [1 2] [4 5]]

let bigHead = [[a b c d] [1 2 3] [4 5 6]]
let bigHeadResult = [[a b c d]; [1 2 3 null] [4 5 6 null]]

use std assert

assert (($test | behead) == $testResult)
assert (($smallHead | behead) == $smallHeadResult)
assert (($bigHead | behead) == $bigHeadResult)
