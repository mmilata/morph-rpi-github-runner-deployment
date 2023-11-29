{ config, pkgs, lib, ... }:

{
  services.openssh.enable = true;

  services.github-runner = {
    enable = true;
    # This would be cool but needs "personal access token (PAT)" which I don't know how to get.
    ##ephemeral = true;
    extraLabels = [ "hw-t2b1" ];
    name = config.networking.hostName;
    extraEnvironment = {
      # Pass host nixpkgs to the runner.
      NIX_PATH = "nixpkgs=${pkgs.path}";
      # You can also use something else, or nothing at all and set NIX_PATH in the workflow yaml.
      ##NIX_PATH = "nixpkgs=https://github.com/NixOS/nixpkgs/archive/8e5e424b1c059e9ccf5db6a652458e30de05fa3a.tar.gz";
    };
    serviceOverrides = {
      PrivateDevices = false;
      SupplementaryGroups = [ "trezord" ];
    };

    # Configure github credentials.
    url = "https://github.com/mmilata/trezor-firmware";
    tokenFile = "/etc/github-runner-token";

    # Use package from unstable to workaround nixos-23.05 where github-runner depends on insecure nodejs.
    # The block can be commented out if using unstable or 23.11+
    package = let
      nixpkgsUnstable = builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/c757e9bd77b16ca2e03c89bf8bc9ecb28e0c06ad.tar.gz";
        sha256 = "04msycqlccsk1wa78syc4l60557iia6yvarp5pvp0qn1j55mq9f5";
      };
    in (import nixpkgsUnstable { system = pkgs.system; }).github-runner;
  };

  # Installs the trezor udev rules and creates the trezord group.
  services.trezord.enable = true;
  # Disable the actual bridge service.
  systemd.services.trezord.wantedBy = lib.mkForce [];

  # udev rules that allow trezord group access to any USB hub.
  services.udev.extraRules = ''
    # This is for Linux before 6.0:
    SUBSYSTEM=="usb", DRIVER=="usb", MODE="0664", GROUP="trezord"

    # This is for Linux 6.0 or later (ok to keep this block present for older Linux kernels):
    SUBSYSTEM=="usb", DRIVER=="hub", \
      RUN+="${pkgs.bash}/bin/sh -c \"chown -f root:trezord $sys$devpath/*-port*/disable || true\"" \
      RUN+="${pkgs.bash}/bin/sh -c \"chmod -f 660 $sys$devpath/*-port*/disable || true\""

    # Trezor serial console (debug builds only)
    SUBSYSTEM=="tty", ATTRS{product}=="TREZOR", MODE="0660", GROUP="trezord", SYMLINK+="ttyTREZOR"
  '';
}

