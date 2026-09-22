# Secrets management with agenix

Secrets are encrypted with [agenix](https://github.com/ryantm/agenix) using age keys.

## How it works

- Secrets are stored as `.age` encrypted files in `secrets/`
- `secrets/secrets.nix` defines which public keys can decrypt each secret
- Two separate decryption paths exist, depending on who needs the secret:
  - **User-level** (home-manager): decrypts to `$XDG_RUNTIME_DIR/agenix/` at home-manager
    activation. Needs a passwordless age key at `~/.config/age/keys.txt` on that machine
    (see "Setup on a new machine" below). Use this for anything a logged-in user's own
    programs need (ssh keys, cli tokens, etc).
  - **System-level** (NixOS `age.secrets`, e.g. `modules/pocket-id`): decrypts to
    `/run/agenix/` during system activation, for root-managed systemd services that must
    work at boot regardless of whether anyone is logged in. Identity defaults to the host's
    own SSH host key (`/etc/ssh/ssh_host_ed25519_key`) — nothing to generate or place
    manually, since every NixOS machine already has one. Recipients still need the host's
    key added to `secrets.nix` (see "Add a system-level secret" below).

## Setup on a new machine (user-level secrets)

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

## Add a new user-level secret

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

## Add a system-level secret (for a root-managed systemd service)

Use this when the consumer is a NixOS service, not a logged-in user's own programs —
it decrypts to `/run/agenix/` at system activation instead of a user's runtime dir, so it's
available at boot even with nobody logged in.

1. Get the target host's own SSH public key:
   ```
   ssh root@<host> cat /etc/ssh/ssh_host_ed25519_key.pub
   ```

2. Add the raw `ssh-ed25519 ...` string to `secrets/secrets.nix` as a new named recipient
   (alongside, not instead of, the personal keys — personal keys let you edit the secret
   from your own machine, the host key lets the host decrypt it itself). agenix/age accept
   SSH public keys as recipients directly — **do not** run it through `ssh-to-age` first:
   nixpkgs' `ssh-to-age` produces a key that looks valid but does not actually match what
   `age` derives from the same SSH private key at decrypt time, so anything encrypted to
   the converted key silently fails with "no identity matched any of the recipients".
   ```nix
   let
     marcusHost = "ssh-ed25519 AAAA... root@marcus";
   in
   {
     "my-secret.age".publicKeys = [ marcus mudada marcusHost ];
   }
   ```

3. Create and encrypt the secret (from a machine with a key already in the recipient list):
   ```
   agenix -e my-secret.age
   ```

4. Declare it in the relevant NixOS module (not `home/`), no `identityPaths` override needed
   — it defaults to the host's own SSH host key automatically:
   ```nix
   age.secrets.my-secret.file = ../../secrets/my-secret.age;
   ```

5. Reference `config.age.secrets.my-secret.path` — e.g. via
   `systemd.services.<name>.serviceConfig.EnvironmentFile` for a password/token a service
   reads from its environment, or a module's own `credentials`/`*File` option if it has one
   (preferred when available — it avoids a raw env-var passthrough).

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

