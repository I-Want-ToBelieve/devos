{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
  with inur; [
    xdotool
    flameshot
    tdrop
    autohide-tdrop
  ];

  services.sxhkd = {
    enable = true;
    keybindings = {
      "shift + BackSpace" = "xdotool key Delete";
      "super + Return" = "kitty";
      "F1" = "flameshot gui";
      "ctrl + t" = "tdrop -n tdrop_terminal --post-create-hook \"autohide-tdrop &\" -ma -h 60% -w 70% -x 15% -y 0 kitty --class=tdrop_terminal";
      "ctrl + grave" = "toggle-vscode-terminal";
      "ctrl + g" = "copyq toggle";
      "super + Escape" = "pkill -USR1 -x sxhkd";
    };
  };
}
