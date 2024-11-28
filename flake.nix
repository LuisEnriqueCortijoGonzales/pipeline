{
  description =
    "Flake with the tools to be used during the Computer architecture course @Utec.";

  inputs = {

    flakelight.url = "github:nix-community/flakelight";

    nix-xilinx.url = "gitlab:doronbehar/nix-xilinx";

  };

  outputs = { nixpkgs, flakelight, nix-xilinx, ... }:
    flakelight ./. {
      inputs.nixpkgs = nixpkgs;
      nixpkgs.config = { allowUnfree = true; };

      devShell = {
        packages = pkgs:
          with pkgs;
          [

            verilog
            gtkwave

            coreutils

            xterm

            python3
          ] ++ (with nix-xilinx.packages.x86_64-linux; [ vivado vitis ])
          ++ (with python312Packages; [ keystone-engine ]);
        shellHook = nix-xilinx.shellHooksCommon;

      };
    };

}
