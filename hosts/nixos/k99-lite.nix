{
  suites,
  profiles,
  inputs,
  pkgs,
  config,
  lib,
  self,
  modulesPath,
  ...
}: {
  imports =
    [(modulesPath + "/installer/scan/not-detected.nix")]
    ++ [
      inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
      inputs.nixos-hardware.nixosModules.common-gpu-amd
    ];

  # amd gpu
  boot.blacklistedKernelModules = ["nouveau"];
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
  ];

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs;
        pkgs.lib.mkForce [
          (vaapiIntel.override {enableHybridCodec = true;})
          vaapiVdpau
          libvdpau-va-gl
          intel-media-driver
        ];
    };

    amdgpu = {
      amdvlk = true;
      opencl = true;
    };

    bluetooth = {
      enable = true;
      package = pkgs.bluez;
    };

    enableRedistributableFirmware = true;
    pulseaudio.enable = false;
  };

  boot = {
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [];

    supportedFilesystems = ["btrfs"];

    initrd = {
      availableKernelModules =
        [
          "xhci_pci"
          "ehci_pci"
          "ahci"
          "nvme_core"
          "nvme"
          "usb_storage"
        ]
        ++ config.boot.initrd.luks.cryptoModules;
      kernelModules = ["dm-snapshot"];
      luks.devices.luksroot = {
        device = "/dev/disk/by-label/cryptroot";
        preLVM = true;
        allowDiscards = true;
      };
    };

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };

      systemd-boot.enable = false;

      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        enableCryptodisk = true;
        configurationLimit = 5;
      };
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
      "noatime"
      "ssd"
      "space_cache=v2"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/root";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
      "noatime"
      "ssd"
      "space_cache=v2"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/root";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
      "ssd"
      "space_cache=v2"
    ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/root";
    fsType = "btrfs";
    options = [
      "subvol=log"
      "compress=zstd"
      "noatime"
      "ssd"
      "space_cache=v2"
    ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-label/swap";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  # compresses half the ram for use as swap
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  virtualisation = {
    spiceUSBRedirection.enable = true;

    docker = {
      enable = true;
    };

    podman = {
      enable = true;
      extraPackages = with pkgs; [
        skopeo
        conmon
        runc
      ];
    };

    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf = {
          enable = true;
          packages = with pkgs; [OVMFFull.fd];
        };
        swtpm.enable = true;
      };
    };
  };

  services = {
    btrfs.autoScrub.enable = true;
    acpid.enable = true;
    thermald.enable = true;
    upower.enable = true;

    tlp = {
      enable = false;
      settings = {
        START_CHARGE_THRESH_BAT0 = 0;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    xserver.videoDrivers = ["amdgpu"];
  };

  xdg.portal = {
    enable = true;
    wlr.enable = false;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      acpi
      brightnessctl
      docker-client
      docker-compose
      docker-credential-helpers
      libva-utils
      ocl-icd
      qt5.qtwayland
      qt5ct
      virt-manager
      vulkan-tools
    ];
  };
}
