{ pkgs }:

let
  # Combined CA bundle: standard CAs + custom CAs for skyori, neoplatform, ff.ru, SRVHADCS.
  # Mounted into the playwright container so Chrome and Node.js trust these CAs.
  combinedCABundle = pkgs.runCommand "combined-ca-bundle.crt" {
    buildInputs = [ pkgs.cacert ];
  } ''
    cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt \
        ${./../common/modules/cert/ca-ff.ru.crt} \
        ${./../common/modules/cert/ca-skyori.ru.crt} \
        ${./../common/modules/cert/ca-neoplatform.ru.crt} \
        ${./../common/modules/cert/SRVHADCS-CA.crt} > $out
  '';

  caBundleArg = "-v";
  caBundleVal = "${combinedCABundle}:/etc/ssl/certs/ca-certificates.crt:ro";
  nodeExtraCA = "-e";
  nodeExtraCAVal = "NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt";

  playwrightTmpArg = "-v";
  playwrightTmpVal = "/tmp/.playwright-mcp:/tmp/.playwright-mcp";
in
{
  nixos = {
    type = "local";
    command = [ "mcp-nixos" ];
    enabled = true;
  };
  daisyui = {
    type = "local";
    command = [
      "docker"
      "run"
      "-i"
      "--rm"
      "daisyui-mcp"
    ];
    enabled = true;
  };
  svelte = {
    type = "remote";
    url = "https://mcp.svelte.dev/mcp";
    enabled = true;
  };
  lucide-icons = {
    type = "local";
    command = [
      "npx"
      "lucide-icons-mcp"
      "--stdio"
    ];
    enabled = true;
  };

  wiki = {
    type = "local";
    command = [ "qmd" "mcp" ];
    enabled = true;
  };

  hound = {
    type = "remote";
    url = "http://localhost:8765/mcp";
    enabled = true;
  };

  playwright = {
    type = "local";
    command = [
      "docker"
      "run"
      "-i"
      "--rm"
      "--init"
      "--network"
      "host"
      caBundleArg
      caBundleVal
      nodeExtraCA
      nodeExtraCAVal
      playwrightTmpArg
      playwrightTmpVal
      "playwright-mcp"
    ];
    enabled = true;
  };

  groups = {
    nixos = [ "nixos" ];
    frontend = [ "svelte" "daisyui" "lucide-icons"];
    wiki = [ "wiki" ];
  };

  claudeCode = {
    hound = {
      type = "url";
      url = "http://localhost:8765/mcp";
    };
    playwright = {
      type = "stdio";
      command = "docker";
      args = [
        "run" "-i" "--rm" "--init"
        "--network" "host"
        caBundleArg caBundleVal
        nodeExtraCA nodeExtraCAVal
        playwrightTmpArg playwrightTmpVal
        "playwright-mcp"
      ];
    };
  };
}
