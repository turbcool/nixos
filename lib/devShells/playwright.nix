{ pkgs, inputs }:

let
  playwright-cli = pkgs.buildNpmPackage {
    pname = "playwright-cli";
    version = "0.1.13";
    src = inputs.playwright-cli;
    npmDepsHash = "sha256-Ulp6IttsZcOOA7LaYDpVKkBYbe2j4RFG8lJARWifOSk=";
    dontNpmBuild = true;

    env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";

    meta.mainProgram = "playwright-cli";
  };
in
{
  devShell = pkgs.mkShellNoCC {
    packages = [
      playwright-cli
      pkgs.chromium
    ];

    shellHook = ''
      mkdir -p .playwright
      cat > .playwright/cli.config.json << 'CONF'
      ${
        builtins.toJSON {
          browser = {
            browserName = "chromium";
            launchOptions.executablePath = "${pkgs.chromium}/bin/chromium";
          };
        }
      }
      CONF

      chmod -R u+w .opencode/skills/playwright-cli 2>/dev/null || true
      rm -rf .opencode/skills/playwright-cli
      mkdir -p .opencode/skills/playwright-cli
      cp -rL --no-preserve=mode ${inputs.playwright-cli}/skills/playwright-cli/ .opencode/skills/playwright-cli/
    '';
  };
}
