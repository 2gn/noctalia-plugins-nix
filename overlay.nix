final: prev: let
  repoSrc = prev.fetchFromGitHub {
    # https://github.com/noctalia-dev/official-plugins
    owner = "noctalia-dev";
    repo = "official-plugins";
    rev = "f36c62aae9bb5d7aa463730139aa19c569a355f3";
    hash = "sha256-D3KIaKkicssbVM8lLXBNTKhsXArXBr55NVZJ+a5Inc8=";
  };

  # Helper function to generate Noctalia plugin derivations
  mkNoctaliaPlugin = { pname, version ? "1.0.0", src, ... }@args:
    prev.stdenv.mkDerivation ({
      pname = pname;
      version = version;
      inherit src;

      unpackPhase = ''
        runHook preUnpack
        cp -r $src ./source
        cd ./source
        chmod -R +w .
        runHook postUnpack
      '';

      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/noctalia/plugins/${pname}
        cp -r . $out/share/noctalia/plugins/${pname}
        runHook postInstall
      '';
    } // (builtins.removeAttrs args [ "pname" "version" "src" ]));

    pluginNames = [
      "bongocat"
      "wallhaven"
    ];
in {
  noctaliaPlugins = final.lib.genAttrs pluginNames (pname:
    mkNoctaliaPlugin {
      inherit pname;
      src = "${repoSrc}/${pname}";
    }
  );
}
