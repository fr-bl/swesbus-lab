# Swesbus lab

Configuration files for the Swesbus lab.

## Lab Manager

The Lab Manager is a bootable ISO that can be used to set up
[thin clients](https://en.wikipedia.org/wiki/Thin_client).

### Usage

1. Download the
   [latest ISO](https://nightly.link/fr-bl/swesbus-lab/workflows/build/main/lab-manager-iso).
   If the artifact expired, build a new ISO
   [with GitHub Actions](#with-github-actions).
2. Boot the ISO on one of the PCs.
3. Follow the steps shown on the login screen.

### Building a custom ISO

A custom Lab Manager ISO can be built to modify the default client
configuration.

#### With Lab Manager

1. Copy and enter the system configuration:

```sh
cp --recursive --no-preserve all /etc/nixos swesbus-lab
cd swesbus-lab
```

2. Modify the default client configuration:

```sh
nano hosts/lab-client/configuration.nix
```

3. Build a custom Lab Manager ISO:

```sh
nix build nix build .#lab-manager-iso
```

4. The generated ISO can be found at `result/iso/`.

#### With GitHub Actions

1. Fork the [GitHub repository](https://github.com/fr-bl/swesbus-lab/fork).
2. Modify the default client configuration at
   `hosts/lab-client/configuration.nix`.
3. Run the "Build" Action.
4. After the Action finished, download its artifact.
