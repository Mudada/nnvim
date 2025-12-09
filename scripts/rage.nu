use prelude.nu

# rotate the keys for a given secret
#
# Example:
export def rage-rotate [
    keysFile: path # filepath of secrets.nix
    secret: path # secret to rotate
]  {
    let secretKey = $secret | path basename
    let keys = nix eval --json -f $keysFile
        | from json
        | get $secretKey
        | get publicKeys
        | each { |r| [-r $r] }
        | flatten
    print $keys
    rage -j 1p -d $secret | save -f /tmp/s
    rage ...$keys -o $secret /tmp/s
    rm /tmp/s
}
