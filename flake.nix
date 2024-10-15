{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python38;

        pyLdLibs = pkgs.lib.makeLibraryPath (with pkgs; [
          libGL
          stdenv.cc.cc
          glib
          zlib
        ]);

        # Darwin requires a different library path prefix
        wrapPrefix = if (!pkgs.stdenv.isDarwin) then "LD_LIBRARY_PATH" else "DYLD_LIBRARY_PATH";
        patchedPython = (pkgs.symlinkJoin {
          name = "python";
          paths = [ python ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram "$out/bin/python" --prefix ${wrapPrefix} : "${pyLdLibs}"
          '';
        });
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            patchedPython
          ];
        };
      }
    );
}






