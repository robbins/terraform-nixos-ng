{ config, lib, pkgs, inputs, ... }: {
  nixpkgs.hostPlatform = "x86_64-linux";

  # Conflicting definitions from multiple modules
  services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";
  image.extension = lib.mkForce "raw.tar.gz";
  services.openssh.enable = true;

  # Fix sudo (NixOS/nixpkgs/issues/218813)
  services.nscd.enableNsncd = false;

  security.sudo = {
    enable = true;
    # TODO: hack maybe get sshagent in github actions or just restrict to specific rebuild cmd
    extraConfig = ''
      nejrobbins_gmail_com ALL=(ALL) NOPASSWD: ALL
    '';
  };
  services.openssh.passwordAuthentication = false;
  security.sudo.wheelNeedsPassword = false;

  system.nixos.variant_id = "installer";

  nix.settings = {
    trusted-users = [ "nejrobbins_gmail_com" ];
    trusted-public-keys = [ "robbins-page-deploy:w0blTbOHTQkwfbYRNCB1pv+63HeAcFcnjAFdfmAZv4o=" ];
  };
}
