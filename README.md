# Swesbus lab

This repository contains configuration files for the Swesbus lab.

## Lab Manager

The lab manager is a bootable ISO that can be used to set up
[thin clients](https://en.wikipedia.org/wiki/Thin_client).

### Usage

1. Download the [latest ISO](https://nightly.link/fr-bl/swesbus-lab/workflows/build/master/lab-manager-iso).
2. Boot the ISO on one of the PCs.
3. Follow the steps shown on the login screen.

### Creating a custom ISO

A custom Lab Manager ISO can be built to modify the default client configuration.

1. Modify the default client configuration:
```sh
nano /etc/nixos/hosts/lab-client/configuration.nix
```

2. Build a custom Lab Manager ISO:
```sh
nix build nix build /etc/nixos#lab-manager-iso
```

3. The generated ISO can be found at `result/iso/`.
