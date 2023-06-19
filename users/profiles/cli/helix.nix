{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.helix = {
    enable = true;
    package = inputs.helix.packages.${pkgs.system}.default;
    settings = {
      keys.normal = {
        "{" = "goto_prev_paragraph";
        "}" = "goto_next_paragraph";
        space.space = "file_picker";
        space.w = ":w";
        space.q = ":q";
        "C-d" = ["half_page_down" "align_view_center"];
        "C-u" = ["half_page_up" "align_view_center"];
        "C-q" = ":bc";
        space.u = {
          f = ":format"; # format using LSP formatter
          w = ":set whitespace.render all";
          W = ":set whitespace.render none";
        };
      };
      keys.select = {
        "%" = "match_brackets";
      };
      editor = {
        color-modes = true;
        cursorline = true;
        idle-timeout = 1;
        line-number = "relative";
        scrolloff = 5;
        bufferline = "always";
        true-color = true;
        lsp.display-messages = true;
        rulers = [80];
        indent-guides = {
          render = true;
        };
        rainbow-brackets = true;
        gutters = ["diagnostics" "line-numbers" "spacer" "diff"];
        statusline = {
          separator = "|";
          left = ["mode" "selections" "spinner" "file-name" "total-line-numbers"];
          center = [];
          right = ["diagnostics" "file-encoding" "file-line-ending" "file-type" "position-percentage" "position"];
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };

        whitespace.characters = {
          space = "·";
          nbsp = "⍽";
          tab = "→";
          newline = "⤶";
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "block";
        };
      };
    };

    # override catppuccin theme and remove background to fix transparency
    themes = {
      catppuccin_mocha_transparent = {
        "inherits" = "catppuccin_mocha";
        "ui.background" = "{}";
      };
    };

    languages = {
      language-server = with pkgs; {
        clangd = {
          command = "${clang-tools}/bin/clangd";
          clangd.fallbackFlags = ["-std=c++2b"];
        };
        gopls = {
          command = "${gopls}/bin/gopls";
        };
        typescript-language-server = {
          command = "${nodePackages.typescript-language-server}/bin/typescript-language-server";
          args = ["--stdio"];
        };

        rust-analyzer = {
          command = "${rust-analyzer}/bin/rust-analyzer";
        };

        nil = {
          command = lib.getExe inputs.nil.packages.${system}.default;
        };
      };

      language = with pkgs; [
        {
          name = "cpp";
          auto-format = true;
          formatter = {
            command = "${clang-tools}/bin/clang-format";
            args = ["-i"];
          };
        }
        {
          name = "css";
          auto-format = true;
        }
        {
          name = "go";
          auto-format = true;
          formatter = {
            command = "${go}/bin/gofmt";
          };
        }
        {
          name = "javascript";
          auto-format = true;
          language-server = {
          };
        }
        {
          name = "nix";
          auto-format = true;
          config.nil.formatting.command = ["alejandra" "-q"];
        }
        {
          name = "rust";
          auto-format = true;

          formatter = {
            command = "${rustfmt}/bin/rustfmt";
          };
        }
        {
          name = "typescript";
          auto-format = true;
          formatter = {
            command = "${nodePackages.prettier}/bin/prettier";
          };
        }
      ];
    };
  };

  home.packages = with pkgs; [
    # Dev tools
    alejandra
    asmfmt
    black
    ccls
    clang
    clang-tools
    delve
    elixir_ls
    gawk
    go
    gocode-gomod
    gomodifytags
    gopkgs
    gopls
    gotests
    go-outline
    go-tools
    java-language-server
    kotlin-language-server
    ktlint
    lldb
    nodejs
    rust-bin.stable.latest.default
    rust-analyzer
    rnix-lsp
    selene
    shellcheck
    shfmt
    # solc
    sumneko-lua-language-server
    stylua
    texlab
    uncrustify
    zls
    nodePackages.jsonlint
    nodePackages.jsonlint
    nodePackages.node2nix
    nodePackages.prettier
    nodePackages.pyright
    nodePackages.stylelint
    nodePackages.typescript-language-server
    nodePackages.vls
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodePackages.yarn
  ];
}
