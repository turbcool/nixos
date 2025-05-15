# User accounts and user-specific settings
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs.brave
  ];

  programs.chromium = {
    enable = true;
    extensions = [
    	"nngceckbapebfimnlniiiahkandclblb" # bitwarden
    	"dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
    	"fnaicdffflnofjppbagibeoednhnbjhg" # floccus
    ];

    # Google search provider:
    defaultSearchProviderEnabled = true;
    defaultSearchProviderSearchURL = "https://www.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}";
    defaultSearchProviderSuggestURL = "https://www.google.com/complete/search?output=chrome&q={searchTerms}";

    extraOpts = {
      # Brave-specific
      "BraveRewardsDisabled" = 1;
      "BraveWalletDisabled" = 1;
      "BraveVPNDisabled" = 1;

      # Chrome-specific:
      "PasswordManagerEnabled" = false;
      "SpellcheckEnabled" = true;
      "SpellcheckLanguage" = [
        "ru-RU"
        "en-US"
      ];
 
      # 1 = Restore the last session
      # 4 = Open a list of URLs
      # 5 = Open New Tab Page
      # 6 = Open a list of URLs and restore the last session
      "RestoreOnStartup" = 1;
      # "RestoreOnStartupURLs" = [];

      # 0 = Predict network actions on any network connection
      # 2 = Do not predict network actions on any network connection
      "NetworkPredictionOptions" = 0;

      "HttpsOnlyMode" = "force_enabled";
      "MemorySaverModeSavings" = 1;
      "SearchSuggestEnabled" = true;
    };
  };
}
