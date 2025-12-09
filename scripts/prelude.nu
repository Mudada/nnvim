# Take the first list of a list<list> and use it as the header for a table
export def behead []: list<list<any>> -> table {
  let header = $in | get 0
  let body = $in | skip

  $body | ~> table $header
}

# Je me souviens plus
export def "~> list" []: [
  string -> list<list<string>>
  binary -> list<list<string>>
] {
   $in | lines | par-each {
    $in
    | split row -r '\s{2,}'
    | each { str trim }
    | where {|x| ($x | is-not-empty) and ($x != " ") }
  } | where { $in | is-not-empty }
}

# Convert a list to a table with the given header
export def "~> table" [header: list<string>]: any -> table {
  let indexedHeader = $header | enumerate
  $in | par-each { |row|
    $indexedHeader | reduce --fold {} {|it, acc|
      $acc | merge {($it | get item): ($row | get -o ($it | get -o index))}
    }
 }
}

# Find the index of an element in a list
export def "find index" [
    elem: any # Element to search
]: list<any> -> any {
    try {
        $in | enumerate | each { |i| if ($i.item == $elem) { $i.index } } | first
    } catch { |err|
        match $err.msg {
            "Row number too large (empty content)." => {
                error make {
                    msg: "Element not found in list",
                    label: {text: "Cannot find this element's index", span: (metadata $elem).span}
                }
            }
        }
    }
}


# = = = = = = TEST = = = = = = #

def "test prelude" []: nothing -> nothing {

    use std assert

    def "test behead" [] {
        let test = [[a b c] [1 2 3] [4 5 6]]
        let testResult = [[a b c]; [1 2 3] [4 5 6]]

        let smallHead = [[a b] [1 2 3] [4 5 6]]
        let smallHeadResult = [[a b]; [1 2] [4 5]]

        let bigHead = [[a b c d] [1 2 3] [4 5 6]]
        let bigHeadResult = [[a b c d]; [1 2 3 null] [4 5 6 null]]

        assert (($test | behead) == $testResult)
        assert (($smallHead | behead) == $smallHeadResult)
        assert (($bigHead | behead) == $bigHeadResult)

    }

    def "test ~> list" [] {
        let testInput = "
        XS ElasticSearch             par0  hds-test                                                               addon_c01a3d59-4fc5-4a2b-8929-c67552766f8b
        XXS Small Space PostgreSQL   par0  test aurrel                                                            addon_ef4cb9fd-9119-4876-a1e8-221500bd825e
        XXS Small Space MySQL        par0  test folder                                                            addon_676eabb7-6ec0-4f86-ab02-562dd50f854f
        "
        let test = ($testInput | ~> list)

        assert (($test | length) == 3)
        assert (($test | where {|t| ($t | length) != 4}) | is-empty)
    }

    def "test find index" [] {
        let list = [1 2 3 4]
        let index = $list | find index 2
        let error = try {
            $list | find index 20
        } catch { |e|
            $e
        }

        assert ($index == 1)
        assert ($error.msg == "Element not found in list")
    }

    test behead
    test ~> list
    test find index

    print "All tests: Ok"
}
