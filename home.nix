{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "hak";
  home.homeDirectory = "/home/hak";


  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.


  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    go
    gcc
    gopls
    lua-language-server
    texlab
    inkscape-with-extensions
    (rWrapper.override {
      packages = with rPackages; [ ggplot2 dplyr xts tidyr gridExtra ggpubr ];
    })

    (rstudioWrapper.override {
      packages = with rPackages; [ ggplot2 dplyr xts tidyr gridExtra ggpubr ];
    })
    wineWowPackages.stable
    # qtcreator
    winetricks
    python3
    gdb
    # sage
    networkmanagerapplet
    protonvpn-gui
    zotero
    (callPackage ../nix-custom-packages/gdb-with-peda/peda.nix {})
    emacs
    coreutils
    # ispell
    # davinci-resolve
    zip
    steam
    steam-run
    nix-search-cli
    # dex
    # lxde.lxsession

    git-filter-repo
    lean4
    pavucontrol
    sqlcmd
    # shotcut
    pciutils
    mesa
    clinfo
    lshw
    pulseaudio
    # morgen
    nix-index

    unixODBC
    unixODBCDrivers.msodbcsql17

    # distrobox

    # julia-bin
    azuredatastudio

    dunst
    zoxide
    fzf

    alacritty-theme
    # valgrind
    # fio

    duf
    gnuplot

    # qbittorrent
    unrar


    zenity


    yazi
    bc

    picom
    acpi
    # uget
    # uget-integrator

    (opera.override { proprietaryCodecs = true; })



    lutris
    busybox
    inetutils
    zoom-us
    htop
    rclone
    restic
    anki
    qemu


    radare2
    man-pages

    ninja
    meson

    obs-studio

  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "davinci-resolve"
      "steam"
      "unrar"
      "steam-original"
      "steam-run"
      "morgen"
      "unixODBC"
      "msodbcsql17"
      "azuredatastudio"
      "opera"
      "lutris"
      "zoom"
    ];






  systemd.user.services.nm-applet = {
    Unit = {
      Description = "NetworkManager Applet";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart =
        "${pkgs.networkmanagerapplet}/bin/nm-applet";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  systemd.user.services.blueman-applet = {
    Unit = {
      Description = "Bluetooth (Blueman)";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };

    # Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      ExecStart = "${pkgs.blueman}/bin/blueman-applet";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };



  systemd.user.services.mssql = {
    Unit = {
      Description = "MSSQL server";
      After = [ "docker.service" "docker.socket" ];
    };

    Service = {
      ExecStart = pkgs.writeScript "mssql.sh" ''
        #!/usr/bin/env bash


if [ "$(docker ps -q -f name=sql1)" ]; then
    echo "MSSQL container is already running."
else
    # Check if the container exists and start it
    if [ "$(docker ps -a -q -f name=sql1)" ]; then
        echo "Starting existing MSSQL container..."
        docker start sql1
    else
        # If the container doesn't exist, create a new one
        echo "Creating and starting a new MSSQL container..."

        ${pkgs.docker}/bin/docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=PASS@p123" \
   -p 1433:1433 --name sql1 --hostname sql1 --restart always \
   -v mssql:/home/hak/mssql mcr.microsoft.com/mssql/server:2022-latest 

    fi
fi

      '';
      ExecStop = "${pkgs.docker}/bin/docker stop sql1";
      ExecReload = "${pkgs.docker}/bin/docker restart sql1";
      Restart="no";
    };
  };




  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".background-image".source = /home/hak/hdd/wallpapers/punk.jpg;


  };

  home.file."~/.config/hypr/hyprland.conf".text = ''
    decoration {
      shadow_offset = 0 5
      col.shadow = rgba(00000099)
    }

    $mod = SUPER
    bind = $mainMod, Return, exec, alacritty
    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow
    bindm = $mod ALT, mouse:272, resizewindow
  '';


  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/hak/etc/profile.d/hm-session-vars.sh
  #

  home.sessionVariables = {
    CPATH = "${pkgs.unixODBC}/include:$CPATH";
    LIBRARY_PATH = "${pkgs.unixODBC}/lib:$LIBRARY_PATH";
    LD_LIBRARY_PATH = "${pkgs.unixODBC}/lib:$LD_LIBRARY_PATH";
    EDITOR = "nvim";
  };
  #services.xserver.displayManager.setupCommands = "xhost +local:docker\n";


  services.dunst.enable = true;

  services.picom = {
    enable = true;
    fade = true;
    inactiveOpacity = 0.7;
    activeOpacity = 1;
    settings = {
      blur = {
        method = "guassian";
        size=10;
        deviation=5.0;
      };
      opacity-rule = [
        "90:class_g = 'Alacritty'"
      ];
    };
  };



  qt.enable = true;
  qt.platformTheme.name = "gtk";
  qt.style.name = "adwaita-dark";


  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
    ];
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    newSession = true;
    escapeTime = 0;

    secureSocket = false;

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
      # tmuxPlugins.tokyo-night-tmux
      tmuxPlugins.catppuccin
      tmuxPlugins.fuzzback
      tmuxPlugins.extrakto
      tmuxPlugins.jump
      tmuxPlugins.tilish
    ];

    extraConfig = ''

set-option -g default-shell ${pkgs.fish}/bin/fish

set -ga terminal-overrides ",screen-256color*:Tc"
set-option -g default-terminal "screen-256color"
set -g status-style 'bg=#333333 fg=#5eacd3'


set-option -g mouse on 

bind -r ^ last-window

bind -r / split-window -h -c "#{pane_current_path}"
bind -r - split-window -v -c "#{pane_current_path}"
bind a last-window

bind r source-file ~/.config/tmux/tmux.conf

set-window-option -g mode-keys vi
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

set -g @catppuccin_flavour 'mocha'

    '';

  };


  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "hak";
    userEmail = "hasifkhan.447@gmail.com";

    aliases = {
      co = "checkout";
      ci = "commit";
      cia = "commit --amend";
      s = "status";
      b = "branch";
      p = "pull";
      pu = "push";
    };

    iniContent = {
      branch.sort = "-committerdate";

      rerere.enabled = true;
    };

    ignores = [ "*~" "*.swp" ];
    lfs.enable = true;

    delta = {
      enable = true;
      options = {
        features = "decorations";
        navigate = true;
        light = false;
        side-by-side = true;
      };
    };

    extraConfig = {
      init.defaultBranch = "master";
      core.editor = "nvim";
      credential.helper = "store --file ~/.git-credentials";
      pull.rebase = "false";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        lightTheme = false;
        activeBorderColor = [ "white" "bold" ];
        inactiveBorderColor = [ "white" ];
        selectedLineBgColor = [ "reverse" "white" ];
      };
    };
  };


  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      ${pkgs.zoxide}/bin/zoxide init fish | source

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end


    '';
    shellAliases = {
      z = "zoxide";
      g = "git";
      gg = "lazygit";
      "..." = "cd ../..";
      nd = "nix develop";
      ns = "nix-search";
      v = "nvim";
      py = "python";
      l = "ls --color=auto";
      ll = "ls -la --color=auto";
      c = "clear";
      dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME/.config";

    };
  };

  programs.alacritty = {
    enable = true;
    # settings.import = [ pkgs.alacritty-theme.dark_pride ];
  };

  



  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
