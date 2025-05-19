let
  # nixos-23.05 as of 2023-11-19
  pinnedNixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/8e5e424b1c059e9ccf5db6a652458e30de05fa3a.tar.gz";
    sha256 = "1hm8gx5jsabf14m7wp4mci80032l3v1fwf7ln90rk6p8xf4bl1rj";
  };
  # can also point to channel on deploy machine
  ##pinnedNixpkgs = <nixpkgs>;
in
{
  network = {
    # Major limitation of morph is that you cannot use different major version of nixpkgs for
    # the whole network and for some hosts. Architecture can differ however.
    pkgs = import pinnedNixpkgs {
      config.allowUnfree = true;
    };
    description = "example arm64 github runner network";
  };

  trezor-ci-rpi = { config, pkgs, lib, ... }: {
    deployment = {
      targetHost = "10.42.42.183";
      targetUser = "root";

      # See also: https://search.nixos.org/options?channel=23.05&show=services.github-runners.%3Cname%3E.tokenFile
      secrets = {
        github-runner-token = {
          source = "./secrets/pi-01/github-runner-token";
          destination = "/etc/github-runner-token";
          owner.user = "root";
          owner.group = "root";
          permissions = "0400";
          action = [ "systemctl" "restart" "github-runner-trezor-rpi-ci" ];
        };
      };
    };
    # Arch needs to be set explicitly.
    nixpkgs.pkgs = import pinnedNixpkgs { system = "aarch64-linux"; config.allowUnfree = false; };

    imports = [
      ./env.nix
      ./hardware/pi-01.nix
      ./machines/github-runner.nix
    ];
  };

  trezor-ci-chromebox = { config, pkgs, lib, ... }: {
    deployment = {
      targetHost = "10.42.42.192";
      targetUser = "root";

      # See also: https://search.nixos.org/options?channel=23.05&show=services.github-runners.%3Cname%3E.tokenFile
      secrets = {
        github-runner-token = {
          source = "./secrets/chromebox-01/github-runner-token";
          destination = "/etc/github-runner-token";
          owner.user = "root";
          owner.group = "root";
          permissions = "0400";
          action = [ "systemctl" "restart" "github-runner-trezor-rpi-ci" ];
        };
      };
    };
    # Defaults to network.pkgs.
    nixpkgs.pkgs = import pinnedNixpkgs { };

    # some tests require boards with Optiga that has security monitor disabled
    services.github-runner.extraLabels = [ "hw-t2b1" "hw-t2b1-nosecmonitor" ];

    imports = [
      ./env.nix
      ./hardware/chromebox-01.nix
      ./machines/github-runner.nix
    ];
  };
}
