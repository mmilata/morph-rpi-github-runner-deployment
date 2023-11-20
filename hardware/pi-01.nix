{ config, lib, pkgs, modulesPath, ... }:

{
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [ "xhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888"; # wat
      fsType = "ext4";
    };

  swapDevices = [ ];

  networking.interfaces.end0.useDHCP = true;
  networking.wireless.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # Not sure where to put this.
  system.stateVersion = "23.05"; # Did you read the comment?
}
