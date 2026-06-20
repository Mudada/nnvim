let
  marcus = "age163e0uf6lzp3wzwx0wxv5p2mvlxrj5qg5hxmcuamenm2hxw3grsss83rgen";
  mudada = "age14vxkzlmesyee6vjq0n4heyjfzx42fpd0xrypumgf9tzsn9fym9ssry3uqj";
  arthur = "age1s4n6hlzt0qvma44esphvzxplw33te9y2uwm79a6jlvu5q0s0ncqs9rq58r";
in
{
  "ssh-personal.age".publicKeys = [
    marcus
    mudada
  ];
  "arthur-authorized-keys.age".publicKeys = [
    arthur
    mudada
  ];
  "forgejo-runner-token.age".publicKeys = [
    arthur
    mudada
  ];
}
