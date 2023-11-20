# global configuration

{ config, pkgs, lib, ... }:

{
  # needed by morph
  security.sudo.enable = true;

  time.timeZone = "Europe/Amsterdam";

  users.extraUsers.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJnGF64XLYyMOHcnyNmLCIvKtArMGGaKIb5nyCwoyltF mmilata" ];

  environment.systemPackages = with pkgs; [
    vim wget git tmux tree ripgrep fd
  ];
}

