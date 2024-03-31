{
  config,
  pkgs,
  lib,
  ...
}: let
  user = "user";
  hashedPassword = "$y$j9T$S6GQmMWVSaLC9akC6aPcd1$3HV1XwIjUAR18ZwEriXXw3MRu/PUHld7lAFRsY1R.KA";
  SSID = "example";
  SSIDpassword = "example";
  interface = "wlan0";
  hostname = "example";
in {
  imports = [];
  nixpkgs = {
    overlays = [
      (self: super: {
        waybar = super.waybar.overrideAttrs (oldAttrs: {
          mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
        });
      })
    ];
  };
   nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 0;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };

  networking = {
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [22 53 80 443];
      allowedUDPPorts = [53];
    };
    hostName = hostname;
    extraHosts = ''
      192.168.10.3 ${hostname}.local
    '';
    wireless = {
      enable = true;
      networks."${SSID}".psk = SSIDpassword;
      interfaces = [interface];
    };
    dhcpcd.enable = false;
    interfaces = {
      end0.useDHCP = false;
      end0.ipv4.addresses = [
        {
          address = "192.168.10.3";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "192.168.10.1";
    nameservers = ["1.1.1.3" "1.0.0.3"];
  };

  environment.shells = with pkgs; [zsh];

  environment.systemPackages = with pkgs; [
    btop
    dconf
    docker
    docker-compose
    git
    hyprland
    libraspberrypi
    lsd
    meslo-lgs-nf
    meson
    neofetch
    neovim
    qt5.qtwayland
    qt6.qmake
    qt6.qtwayland
    pulseaudio
    raspberrypi-eeprom
    swww
    wayland-protocols
    wayland-utils
    wl-clipboard
    wlroots
    wofi
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xwayland
    zsh
  ];

  # Hint Electon apps to use wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  virtualisation.docker.enable = true;

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  services = {
    openssh.enable = true;
    xserver.displayManager.sddm.wayland.enable = true;
  };

  security = {
    polkit.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
    users."${user}" = {
      inherit hashedPassword;
      isNormalUser = true;
      openssh.authorizedKeys.keys = [];
      extraGroups = ["wheel" "docker"];
    };
  };

  # sound.enable = true;

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
    # raspberry-pi."4".fkms-3d.enable = true;
    # pulseaudio.enable = true;
    # raspberry-pi."4".audio.enable = true;
    enableRedistributableFirmware = true;
  };

  programs = {
    dconf.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    zsh.enable = true;
  };
  system.stateVersion = "23.11";
}
