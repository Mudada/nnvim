let
  marcus = "age163e0uf6lzp3wzwx0wxv5p2mvlxrj5qg5hxmcuamenm2hxw3grsss83rgen";
  mudada = "age14vxkzlmesyee6vjq0n4heyjfzx42fpd0xrypumgf9tzsn9fym9ssry3uqj";
in
{
  "ssh-personal.age".publicKeys = [
    marcus
    mudada
  ];
}
