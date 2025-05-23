let
  # nixos-24.11 as of
  pinnedNixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/9b5ac7ad45298d58640540d0323ca217f32a6762.tar.gz";
    sha256 = "0zqvvkb1gsqxvm2vvp184spm1kc363sx0byv7cdxmmj4wk51kfv1";
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
    description = "example github runner network";
  };

  trezor-ci-nuc-01 = { config, pkgs, lib, ... }: {
    deployment = {
      targetHost = "10.42.42.58";
      targetUser = "root";

      # See also: https://search.nixos.org/options?channel=23.05&show=services.github-runners.%3Cname%3E.tokenFile
      secrets = {
        github-runner-token = {
          source = "./secrets/nuc-01/github-runner-token";
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

    # services.github-runner.extraLabels = [ "hw-t3t1" ];

    imports = [
      ./env.nix
      ./hardware/nuc-01.nix
      ./machines/github-runner.nix
    ];
  };

  trezor-ci-nuc-02 = { config, pkgs, lib, ... }: {
    deployment = {
      targetHost = "10.42.42.83";
      targetUser = "root";

      # See also: https://search.nixos.org/options?channel=23.05&show=services.github-runners.%3Cname%3E.tokenFile
      secrets = {
        github-runner-token = {
          source = "./secrets/nuc-02/github-runner-token";
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

    # services.github-runner.extraLabels = [ "hw-t3t1" ];

    imports = [
      ./env.nix
      ./hardware/nuc-02.nix
      ./machines/github-runner.nix
    ];
  };
}
