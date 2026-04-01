# Swesbus Lab Manual

<h2 id="toc">Table of Contents</h2>

- [About this manual](#manual)
- [Obtaining the Lab Manager ISO](#iso)
- [Using the Lab Manager](#lab-manager)

<h2 id="manual">About this manual</h2>

This manual is [available online](https://fr-bl.github.io/swesbus-lab). To read it locally, run:

```sh
$ lab-help
```

<h2 id="iso">Obtaining the Lab Manager ISO</h2>

### From GitHub

The latest Lab Manager ISO can be downloaded [from GitHub actions](https://nightly.link/fr-bl/swesbus-lab/workflows/build/main/lab-manager-iso). If the artifact has expired, build a new ISO as explained below.

### Building a custom ISO

A custom Lab Manager ISO can be built to modify the default client
configuration.

#### With Lab Manager

1. Copy and enter the system configuration:

```sh
$ cp --recursive --no-preserve all /etc/nixos swesbus-lab
$ cd swesbus-lab
```

2. Modify the default client configuration:

```sh
$ nano hosts/lab-client/configuration.nix
```

3. Build a custom Lab Manager ISO:

```sh
$ nix build nix build .#lab-manager-iso
```

4. The generated ISO can be found at `result/iso/`.

#### With GitHub Actions

1. Fork the [GitHub repository](https://github.com/fr-bl/swesbus-lab/fork).
2. Modify the default client configuration at
   `hosts/lab-client/configuration.nix`.
3. Run the "Build" Action.
4. After the Action finished, download its artifact.

<h2 id="lab-manager">Using the Lab Manager</h2>

The Lab Manager is a bootable ISO that can be used to install
[thin clients](https://en.wikipedia.org/wiki/Thin_client).

### Networking

To set up a wireless connection, run:

```sh
$ nmtui
```

### Configuration

To copy and enter the client configuration, run:

```sh
$ cp --recursive --no-preserve all /etc/nixos swesbus-lab
$ cd swesbus-lab
```

To edit the client configuration, run:

```sh
$ nano hosts/lab-client/configuration.nix
```

### Partitioning

To list available disks, run:

```sh
$ lsblk
```

To *irrevocably* erase, format and mount disk /dev/mmcblk0, run:
```sh
$ sudo disko --mode destroy,format,mount --flake .#lab-client-1
```

### Installation

To install Lab Client 1 onto the mounted disk, run:

```sh
$ sudo nixos-install --flake .#lab-client-1
```

### Wrapping up

To restart the system, run:

```sh
$ reboot
```

To power off the system instead, run:

```sh
$ shutdown now
```
