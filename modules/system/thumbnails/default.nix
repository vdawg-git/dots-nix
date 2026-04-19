{pkgs}: let
  script = pkgs.writeShellApplication {
    name = "exiv2-thumbnailer";
    runtimeInputs = [pkgs.exiv2 pkgs.imagemagick];
    text = builtins.readFile ./exiv2-thumbnailer.sh;
  };

  thumbnailer = pkgs.writeTextFile {
    name = "exiv2-thumbnailer.thumbnailer";
    destination = "/share/thumbnailers/exiv2-thumbnailer.thumbnailer";
    text = ''
      [Thumbnailer Entry]
      TryExec=${script}/bin/exiv2-thumbnailer
      Exec=${script}/bin/exiv2-thumbnailer %i %o %s
      MimeType=image/x-3fr;image/x-adobe-dng;image/x-arw;image/x-bay;image/x-canon-cr2;image/x-canon-cr3;image/x-canon-crw;image/x-cap;image/x-cr2;image/x-crw;image/x-dcr;image/x-dcraw;image/x-dcs;image/x-dng;image/x-drf;image/x-eip;image/x-erf;image/x-fff;image/x-fuji-raf;image/x-iiq;image/x-k25;image/x-kdc;image/x-mef;image/x-minolta-mrw;image/x-mos;image/x-mrw;image/x-nef;image/x-nikon-nef;image/x-nrw;image/x-olympus-orf;image/x-orf;image/x-panasonic-raw;image/x-pef;image/x-pentax-pef;image/x-ptx;image/x-pxn;image/x-r3d;image/x-raf;image/x-raw;image/x-rw2;image/x-rwl;image/x-rwz;image/x-sigma-x3f;image/x-sony-arw;image/x-sony-sr2;image/x-sony-srf;image/x-sr2;image/x-srf;image/x-x3f;image/x-panasonic-rw2;
    '';
  };
in
  pkgs.symlinkJoin {
    name = "exiv2-thumbnailer";
    paths = [thumbnailer];
  }
