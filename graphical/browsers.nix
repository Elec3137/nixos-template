{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    ungoogled-chromium
  ];

  programs.chromium = {
    # enable = true;

    # this won't work until https://github.com/NixOS/nixpkgs/pull/394028
    # package = pkgs.ungoogled-chromium;

    # note: you cannot use policies to install extensions on ungoogled-chromium
    # https://github.com/ungoogled-software/ungoogled-chromium/issues/1629
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin *not working?)
      "mnjggcdmjocbbbhaepdhchncahnbgone" # sponsorblock
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      # "ocaahdebbfolfmndjeplogmgcagdmblk" # chromium web store extension for updating other extensions on chromium
    ];

    # set a default search engine (since ungoogled-chromium is missing one)
    # note: this will make it impossible to change search engines while the module is enabled
    defaultSearchProviderEnabled = true;
    defaultSearchProviderSearchURL = "https://www.startpage.com/sp/search?query={searchTerms}";
    defaultSearchProviderSuggestURL = "https://www.startpage.com/osuggestions?q={searchTerms}";
  };

  programs.firefox = {
    # enable = true;
    package = pkgs.librewolf;
    preferences = {
      "privacy.resistFingerprinting" = false; # due to it forcing light theme
      "webgl.disabled" = false;

      # these should only be on by the user's request
      "privacy.clearHistory.cookiesAndStorage" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown_v2.cookiesAndStorage" = false; # this one seems to be the normal setting
    };
  };
}
