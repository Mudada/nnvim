let
  marcus = "age163e0uf6lzp3wzwx0wxv5p2mvlxrj5qg5hxmcuamenm2hxw3grsss83rgen";
  mudada = "age14vxkzlmesyee6vjq0n4heyjfzx42fpd0xrypumgf9tzsn9fym9ssry3uqj";
  # marcus's own SSH host key, for secrets NixOS itself must decrypt at system
  # activation (age.secrets, not home-manager) — see secrets/README.md.
  marcusHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIILc5ktXWAUkHhhVCgXgZ4+2187kRDT+DHgAoxLy0+vf root@marcus";
in
{
  "ssh-personal.age".publicKeys = [
    marcus
    mudada
  ];
  "pocket-id-encryption-key.age".publicKeys = [
    marcus
    mudada
    marcusHost
  ];
  "outline-secret-key.age".publicKeys = [
    marcus
    mudada
    marcusHost
  ];
  "outline-oidc-client-secret.age".publicKeys = [
    marcus
    mudada
    marcusHost
  ];
}
