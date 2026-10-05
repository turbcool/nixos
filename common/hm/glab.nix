{ config, lib, osConfig, pkgs, ... }:

let
  # glab global config template. Tokens are @@SECRET:gitlab-<host>-token@@
  # sentinels resolved at activation from system agenix secret paths, so real
  # tokens never land in the Nix store. CA trust comes from the system store
  # (common/modules/cert.nix), which Go honors via SSL_CERT_FILE.
  template = pkgs.writeText "glab-config.yml" (import ./config/glab-config.nix { });
  secrets = {
    gitlab-neoplatform-token = osConfig.age.secrets.gitlab-neoplatform-token.path;
    gitlab-skyori-token = osConfig.age.secrets.gitlab-skyori-token.path;
  };
in
{
  home.activation.glab = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    out="$HOME/.config/glab-cli/config.yml"
    mkdir -p "$(dirname "$out")"
    ( umask 077
      cfg="$(cat ${template})"
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: path: ''
        cfg="''${cfg//@@SECRET:${name}@@/$(cat ${path} 2>/dev/null || true)}"
      '') secrets)}
      printf '%s\n' "$cfg" > "$out"
    )
    chmod 0600 "$out"
  '';
}
