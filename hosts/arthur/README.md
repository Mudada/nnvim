# arthur

## Rebuild remotely

```nushell
nixos-rebuild switch --flake .#arthur --target-host arthur@<ip> --build-host arthur@<ip> --use-remote-sudo
```

Make sure your SSH key is loaded first:

```nushell
ssh-add ~/.ssh/arthur
```

## Reinstall from scratch

### 1. Boot into Debian

Reinstall the server with a Debian image via the provider's console.
Once up, install sudo and add arthur to sudoers:

```bash
apt-get install -y sudo
echo "arthur ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/arthur
```

### 2. Prepare the age key

The server needs its age private key at `/etc/age/key` to decrypt agenix secrets.
Pass it via nixos-anywhere's `--extra-files`:

```nushell
mkdir -p extra-files/etc/age
cp secrets/arthur.key extra-files/etc/age/key
```

### 3. Run nixos-anywhere

```nushell
nix run github:nix-community/nixos-anywhere -- --build-on remote --extra-files ./extra-files --flake .#arthur root@<ip>
```

After the install the server reboots into NixOS. Connect with:

```nushell
ssh -i ~/.ssh/arthur arthur@<ip>
```
