{ inputs, pkgs, ... }:
let
  username = "vdawg";
  command = "uwsm start hyprland";
in
{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  environment.systemPackages = with pkgs; [
    hyprpicker
    hyprcursor
    hyprlock
    hypridle
    swww
    kitty
    greetd.tuigreet
  ];

  # Enable Display Manager and auto-login
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${command}";
        user = "${username}";
      };
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet 
                    --greeting 'Thou art returned. The sun doth rise on new opportunities ^-^'
                    --remember --remember-session
                    --asterisks-char ▓
                    --time --time-format '%I:%M %p | %a • %h | %F' 
                    --cmd '${command}'
        '';
        user = "greeter";
      };
    };
  };

  users.users.greeter = {
    isNormalUser = false;
    description = "greetd greeter user";
    extraGroups = [
      "video"
      "audio"
    ];
    linger = true;
  };

}
