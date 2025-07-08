{ ... }:

{
  security.pam.services.vdawg.kwallet = {
    name = "kwallet";
    enableKwallet = true;
  };

  /*
    security.pam.loginLimits = [
      {
        domain = "@wheel";
        item = "maxlogins";
        type = "-";
        value = "4";
      }
    ];
  */

}
