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
      inputs.nixos-hardware.nixosModules.common-gpu-intel
      inputs.nixos-hardware.nixosModules.common-gpu-amd
    ];

  # amd gpu
  boot.blacklistedKernelModules = ["nouveau" "nvidia"];
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
    "f /dev/shm/looking-glass 0660 i.want.to.believe qemu-libvirtd -"
  ];

  hardware = {
    opengl = {
      enable = true;
    };

    amdgpu = {
      amdvlk = true;
      opencl = true;
      loadInInitrd = true;
    };

    bluetooth = {
      enable = true;
      package = pkgs.bluez;
    };

    enableRedistributableFirmware = true;
    pulseaudio.enable = false;
  };

  # services.xserver.videoDrivers = ["amdgpu"];
  # @see https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/
  # @see https://viniciusmuller.github.io/blog/NixOS/gpu_passthrough.html#identifying-iommu-devices
  # @see https://nixos.wiki/wiki/IGVT-g
  boot = {
    kernelModules = [
      "kvm-intel" # If using an AMD processor, use `kvm-amd`
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio-mdev"
      "vfio_virqfd"
      "vfio"
      # https://www.reddit.com/r/NixOS/comments/p8bqvu/how_to_install_v4l2looback_kernel_module/?onetap_auto=true
      # Virtual Camera
      "v4l2loopback"
      # Virtual Microphone, built-in
      "snd-aloop"
    ];
    extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
      # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
      # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
      # https://github.com/umlaeute/v4l2loopback
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label="Virtual Camera"
    '';
    extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "intel_iommu=on"
      # "i915.enable_gvt=1"
      # "i915.enable_guc=0"
      "iommu=pt"
      # "earlymodules=vfio-pci"
      # "vfio-pci.ids=8086:1912"
      "pcie_aspm=off"
    ];

    supportedFilesystems = ["btrfs" "ntfs"];

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

  fileSystems."/var/lib/libvirt" = {
    device = "/dev/disk/by-label/qemu-kvm";
    fsType = "ext4";
  };

  fileSystems."/home/i.want.to.believe/Games" = {
    device = "/dev/disk/by-label/SG";
    fsType = "ext4";
    options = [
      "rw"
      "nosuid"
      "nodev"
      "relatime"
      "errors=remount-ro"
    ];
    noCheck = true;
  };

  fileSystems."/run/media/i.want.to.believe/Games" = {
    device = "/dev/disk/by-label/Games";
    fsType = "ntfs3";
    options = [
      "rw"
      "nosuid"
      "nodev"
      "relatime"
      "uid=1000"
      "gid=100"
      "iocharset=utf8"
      "windows_names"
    ];
    noCheck = true;
  };

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

    waydroid.enable = true;
    lxd.enable = true;

    docker = {
      enable = true;
      daemon = {
        settings = {
          registry-mirrors = ["https://registry.docker-cn.com" "https://hub-mirror.c.163.com"];
        };
      };
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
        ovmf = {
          enable = true;
        };
        runAsRoot = false;
      };
    };

    kvmgt = {
      enable = true;
      vgpus = {
        "i915-GVTg_V5_4" = {
          uuid = ["179881f8-f4d8-11ed-8914-23e4dfd5da5b"];
        };
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
  };

  xdg.portal = {
    enable = true;
    wlr.enable = false;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  environment = {
    variables = {
      AMD_VULKAN_ICD = "RADV";
      DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1 = "1";
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
      QT_LOGGING_RULES = "kwin_*.debug=true";
    };

    sessionVariables = {
      # NIXOS_OZONE_WL = "1";
    };

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
      virt-viewer
      vulkan-tools
      vulkan-loader
      wl-clipboard
      ydotool
      vkbasalt
      vkbasalt-cli
      # inur.systemd-shutdown-diagnose
    ];
  };
}
