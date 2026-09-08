# glab global config template. Tokens are @@SECRET:gitlab-<host>-token@@ sentinels
# resolved at activation from /run/agenix — never plaintext here.
# CA trust comes from the system store (common/modules/cert.nix), which Go honors
# via SSL_CERT_FILE, so no ca_cert/skip_tls_verify is needed.
{ }:

builtins.toJSON {
  host = "gitlab.neoplatform.ru";
  hosts = {
    "gitlab.neoplatform.ru" = {
      api_protocol = "https";
      api_host = "gitlab.neoplatform.ru";
      token = "@@SECRET:gitlab-neoplatform-token@@";
    };
    "gitlab.skyori.ru" = {
      api_protocol = "https";
      api_host = "gitlab.skyori.ru";
      token = "@@SECRET:gitlab-skyori-token@@";
    };
  };
}
