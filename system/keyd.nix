{ inputs, pkgs, ... }:

{
  services.keyd.enable = true;
  services.keyd.keyboards.default = {
    ids = [
      "*"
      # Ignore split keyboard
      "-beeb:0002:35429553"
      "-beeb:0002:cb369b64"
      "-beeb:0002:7b9d9329"
      "-beeb:0002:fcb4ba9a"
    ];
    settings = {
      main = {
        # MacOs modifier layout
        leftmeta = "layer(alt)";
        leftcontrol = "layer(meta)";
        leftalt = "layer(control)";

        # Nicer capslock
        # When capslock is held hjkl keys becomes arrow keys
        capslock = "overload(arrow_layer, esc)";

        # MacOs arrow power ( Home / End ) - to be implemented

        # Homerow mods
        # From https://github.com/rvaiya/keyd/issues/437
        a = "overloadt2(shift, a, 220)";
        semicolon = "overloadt2(shift, ;, 220)";
        d = "overloadt2(meta, d, 220)";
        # f = overloadt2(shift, f, 220)
        # s = overloadt2(alt, s, 220);
        # a = overloadt2(control, a, 220)
        # s = overloadt2(alt, s, 220)

      };
      # When tab is held hjkl keys becomes arrow keys
      # tab = overload(arrow_layer, tab)
      arrow_layer = {
        # chord_hold_timeout = 1000
        h = "left";
        j = "down";
        k = "up";
        l = "right";

        e = "home";
        r = "end";
        # TODO when space is held arrow keys go to start/end (home/end/page up/page down)
      };
    };

  };
}
