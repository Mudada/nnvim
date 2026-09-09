#!/usr/bin/env nu
# split-pdf.nu — split a PDF into one file per page, in parallel.
#
# Usage:
#   nu split-pdf.nu input.pdf
#   nu split-pdf.nu input.pdf --out-dir ./pages --prefix page --jobs 8
#
# Requires: qpdf  
def main [
    input: path              # path to the source PDF
    --out-dir: path = "."    # directory to write page-N.pdf files into
    --prefix: string = "page" # filename prefix, e.g. "page" -> page-1.pdf
    --jobs: int = 0          # max parallel workers (0 = let nushell decide)
] {
    if not ($input | path exists) {
        error make { msg: $"Input file not found: ($input)" }
    }

    if (which qpdf | is-empty) {
        error make { msg: "qpdf is not installed or not on PATH. Install it first (e.g. `brew install qpdf`)." }
    }

    mkdir $out_dir

    # Get total page count from qpdf
    let npages = (qpdf --show-npages $input | into int)
    print $"Splitting ($input) \(($npages) pages\) into ($out_dir)/ ..."

    let start = (date now)

    let results = if $jobs > 0 {
        1..$npages | par-each -t $jobs { |i|
            split-one $input $out_dir $prefix $i
        }
    } else {
        1..$npages | par-each { |i|
            split-one $input $out_dir $prefix $i
        }
    }

    let failed = ($results | where success == false)
    let elapsed = ((date now) - $start)

    print $"Done: ($npages - ($failed | length))/($npages) pages written in ($elapsed)."

    if ($failed | length) > 0 {
        print $"⚠️  ($failed | length) page\(s\) failed:"
        $failed | each { |f| print $"  page ($f.page): ($f.error)" }
    }
}

# Extract a single page with qpdf, returns a record with success/error info.
def split-one [input: path, out_dir: path, prefix: string, page: int] {
    let out_file = ($out_dir | path join $"($prefix)-($page).pdf")
    let result = (do -i { qpdf $input --pages . $page -- $out_file } | complete)

    if $result.exit_code == 0 {
        { page: $page, success: true, error: "" }
    } else {
        { page: $page, success: false, error: $result.stderr }
    }
}
