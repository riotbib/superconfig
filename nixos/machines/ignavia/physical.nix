{ self, ... }:
{
  imports = [
    ./config.nix
    ../../2configs/antimicrox
    ./disk.nix
    self.inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
  ];

  networking.hostId = "deadbeef";
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  hardware.opengl.enable = true;
}
