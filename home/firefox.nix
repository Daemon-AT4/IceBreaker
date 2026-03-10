{ config, pkgs, lib, ... }:

{
  # Tell Stylix which Firefox profile to theme
  stylix.targets.firefox.profileNames = [ "archangel" ];

  programs.firefox = {
    enable = true;

    profiles.archangel = {
      isDefault = true;
      name      = "archangel";

      # ── Bookmarks ───────────────────────────────────────────────
      # Shown in the bookmarks toolbar (View → Toolbars → Bookmarks Toolbar).
      bookmarks = {
        force = true;
        settings = [
          {
            name    = "Pentesting";
            toolbar = true;
            bookmarks = [
              {
                name = "HackTricks";
                url  = "https://book.hacktricks.xyz/";
              }
              {
                name = "HackTricks — Red Team";
                url  = "https://book.hacktricks.xyz/generic-methodologies-and-resources/pentesting-methodology";
              }
              {
                name = "HackTheBox";
                url  = "https://www.hackthebox.com/";
              }
              {
                name = "TryHackMe";
                url  = "https://tryhackme.com/";
              }
              {
                name = "daemon-sec.xyz";
                url  = "https://daemon-sec.xyz/";
              }
            ];
          }
        ];
      };

      # ── Preferences ────────────────────────────────────────────
      settings = {
        # Enable userChrome.css / userContent.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Privacy — disable telemetry
        "datareporting.healthreport.uploadEnabled"            = false;
        "datareporting.policy.dataSubmissionEnabled"          = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2"  = false;
        "toolkit.telemetry.enabled"                           = false;
        "toolkit.telemetry.unified"                           = false;

        # UX — sensible defaults
        "browser.startup.homepage"              = "about:blank";
        "browser.newtabpage.enabled"            = false;
        "browser.newtabpage.activity-stream.showSponsored"         = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.shell.checkDefaultBrowser"     = false;
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.tabs.warnOnClose"              = false;

        # Security
        "network.trr.mode"               = 2;
        "dom.security.https_only_mode"   = true;
        "privacy.trackingprotection.enabled" = true;

        # Performance — VMware safe (no GPU acceleration)
        "gfx.webrender.all"                     = false;
        "layers.acceleration.disabled"          = true;
        "media.hardware-video-decoding.enabled" = false;
      };

      # ── Rose Pine dark theme via userChrome.css ─────────────────
      # Themes the browser chrome: tabs, toolbar, urlbar, sidebar.
      userChrome = ''
        /* ── Rose Pine Dark — IceBreaker Firefox theme ──────────── */
        :root {
          --rp-base:    #191724;
          --rp-surface: #1f1d2e;
          --rp-overlay: #26233a;
          --rp-muted:   #6e6a86;
          --rp-subtle:  #908caa;
          --rp-text:    #e0def4;
          --rp-love:    #eb6f92;
          --rp-gold:    #f6c177;
          --rp-pine:    #31748f;
          --rp-foam:    #9ccfd8;
          --rp-iris:    #c4a7e7;

          --toolbar-bgcolor:        var(--rp-base)    !important;
          --toolbar-color:          var(--rp-text)    !important;
          --toolbarbutton-hover-background: var(--rp-overlay) !important;
          --toolbarbutton-active-background: var(--rp-overlay) !important;
        }

        /* ── Window / toolbox ─────────────────────────────────── */
        #navigator-toolbox,
        #navigator-toolbox > toolbar {
          background-color: var(--rp-base) !important;
          color:            var(--rp-text) !important;
          border-color:     var(--rp-overlay) !important;
        }

        /* ── Tabs ─────────────────────────────────────────────── */
        .tab-background {
          background-color: var(--rp-surface) !important;
          border-radius: 6px 6px 0 0 !important;
          margin-top: 2px !important;
        }

        .tab-background[selected="true"],
        .tabbrowser-tab[selected] .tab-background {
          background-color: var(--rp-overlay) !important;
          border-top: 2px solid var(--rp-iris) !important;
        }

        .tab-label {
          color: var(--rp-subtle) !important;
        }

        .tab-label[selected="true"],
        .tabbrowser-tab[selected] .tab-label {
          color: var(--rp-text) !important;
          font-weight: bold !important;
        }

        /* Tab strip background */
        #tabbrowser-tabs,
        #TabsToolbar {
          background-color: var(--rp-base) !important;
        }

        /* New tab button */
        #tabs-newtab-button,
        .tabs-newtab-button {
          color: var(--rp-muted) !important;
        }

        /* ── URL bar ──────────────────────────────────────────── */
        #urlbar,
        #urlbar-background {
          background-color: var(--rp-surface) !important;
          color:            var(--rp-text)    !important;
          border-color:     var(--rp-overlay) !important;
          border-radius:    6px               !important;
        }

        #urlbar:focus-within #urlbar-background {
          border-color: var(--rp-iris)            !important;
          box-shadow:   0 0 0 1px var(--rp-iris)  !important;
        }

        #urlbar-input {
          color: var(--rp-text) !important;
        }

        /* URL bar result panel */
        #urlbar-results {
          background-color: var(--rp-surface) !important;
          color:            var(--rp-text)    !important;
        }

        .urlbarView-row:hover,
        .urlbarView-row[selected] {
          background-color: var(--rp-overlay) !important;
        }

        .urlbarView-url {
          color: var(--rp-foam) !important;
        }

        /* ── Bookmarks toolbar ────────────────────────────────── */
        #PersonalToolbar {
          background-color: var(--rp-surface) !important;
          border-bottom:    1px solid var(--rp-overlay) !important;
          padding:          2px 4px !important;
        }

        .bookmark-item {
          color:            var(--rp-text)    !important;
          border-radius:    4px               !important;
          padding:          2px 6px           !important;
        }

        .bookmark-item:hover {
          background-color: var(--rp-overlay) !important;
          color:            var(--rp-iris)    !important;
        }

        /* ── Navigation buttons ───────────────────────────────── */
        #back-button,
        #forward-button,
        #reload-button,
        #stop-button,
        #home-button {
          color: var(--rp-subtle) !important;
        }

        #back-button:hover,
        #forward-button:hover,
        #reload-button:hover,
        #stop-button:hover,
        #home-button:hover {
          background-color: var(--rp-overlay) !important;
          color:            var(--rp-iris)    !important;
          border-radius:    4px               !important;
        }

        /* ── Menu bar (if shown) ──────────────────────────────── */
        #toolbar-menubar {
          background-color: var(--rp-base)    !important;
          color:            var(--rp-text)    !important;
        }

        /* ── Sidebar ──────────────────────────────────────────── */
        #sidebar-box {
          background-color: var(--rp-surface) !important;
          color:            var(--rp-text)    !important;
        }

        #sidebar-header {
          background-color: var(--rp-overlay) !important;
          color:            var(--rp-text)    !important;
        }

        /* ── Context menus ────────────────────────────────────── */
        menupopup,
        panel {
          background-color: var(--rp-surface) !important;
          color:            var(--rp-text)    !important;
          border:           1px solid var(--rp-overlay) !important;
          border-radius:    6px !important;
        }

        menuitem:hover {
          background-color: var(--rp-overlay) !important;
          color:            var(--rp-iris)    !important;
        }

        menuseparator {
          border-color: var(--rp-overlay) !important;
        }
      '';
    };
  };
}

