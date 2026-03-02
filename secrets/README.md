# Secrets management with agenix

Secrets are encrypted with [agenix](https://github.com/ryantm/agenix) using age keys.

## How it works

- Secrets are stored as `.age` encrypted files in `secrets/`
- `secrets/secrets.nix` defines which public keys can decrypt each secret
- At activation, the home-manager agenix module decrypts secrets to `$XDG_RUNTIME_DIR/agenix/`
- Each machine needs a passwordless age key at `~/.config/age/keys.txt`

## Setup on a new machine

1. Generate an age key:
   ```
   rage-keygen -o ~/.config/age/keys.txt
   ```

2. Add the public key (printed by the command above) to `secrets/secrets.nix`

3. Re-encrypt all secrets so the new key can decrypt them:
   ```
   agenix -r
   ```

4. Rebuild

## Add a new secret

1. Declare the secret's recipients in `secrets/secrets.nix`:
   ```nix
   "my-secret.age".publicKeys = [ marcus ];
   ```

2. Create and encrypt the secret:
   ```
   agenix -e my-secret.age
   ```

3. Declare it in `home/default.nix`:
   ```nix
   age.secrets.my-secret = {
     file = ../secrets/my-secret.age;
   };
   ```

4. Reference `config.age.secrets.my-secret.path` wherever you need the decrypted file path

## Remove a key (machine decommissioned)

1. Remove the public key from `secrets/secrets.nix`
2. Re-encrypt all secrets so the removed key can no longer decrypt them:
   ```
   agenix -r
   ```

## Re-encrypt after changing keys

```
agenix -r
```

This decrypts all secrets with your current key and re-encrypts them for the recipients listed in `secrets/secrets.nix`.

