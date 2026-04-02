# Swesbus Lab Manual

<h2 id="toc">Table of Contents</h2>

- [About this manual](#manual)
- [Obtaining the Lab Manager ISO](#iso)
- [Using the Lab Manager](#lab-manager)
- [Using the Lab Client](#lab-client)

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

#### With GitHub Actions

Fork the [GitHub repository](https://github.com/fr-bl/swesbus-lab/fork). Then, modify the default client configuration at
   `hosts/lab-client/configuration.nix`. Run the "Build" Action and download its artifact when after it finishes.

#### With Lab Manager

To copy the current configuration to a local directory, run:

```sh
$ cp --dereference --recursive --no-preserve all /etc/nixos swesbus-lab
$ cd swesbus-lab
```

To edit the client configuration, open `hosts/lab-client/configuration.nix` in a text editor or run:

```sh
$ nano hosts/lab-client/configuration.nix
```

To build a custom Lab Manager ISO, run:

```sh
$ nix build nix build .#lab-manager-iso
```

The generated ISO can be found at `result/iso/`.

<h2 id="lab-manager">Using the Lab Manager</h2>

The Lab Manager is a bootable ISO that can be used to install
[thin clients](https://en.wikipedia.org/wiki/Thin_client).

### Networking

To set up a wireless connection, run:

```sh
$ nmtui
```

### Configuration

To copy the current configuration to a local directory, run:

```sh
$ cp --dereference --recursive --no-preserve all /etc/nixos swesbus-lab
$ cd swesbus-lab
```

To edit the client configuration, open `hosts/lab-client/configuration.nix` in a text editor or run:

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

<h2 id="lab-client">Using the Lab Client</h2>

The Lab Client is a thin client that automatically connects to an RDP server. It can be installed using the [Lab Manager](#lab-manager).

### Configuration

To copy the current configuration to a local directory, run:

```sh
$ cp --dereference --recursive --no-preserve all /etc/nixos swesbus-lab
$ cd swesbus-lab
```

To edit the client configuration, open `hosts/lab-client/configuration.nix` in a text editor or run:

```sh
$ nano hosts/lab-client/configuration.nix
```

To apply the client configuration, run:

```sh
$ sudo nixos-rebuild switch --flake .
```
