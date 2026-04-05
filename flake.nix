{
  description = "Configurated Emacs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
  };

  outputs = { self, nixpkgs, emacs-overlay }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [ (import emacs-overlay) ];
    };
    emacs-fields = {
      name = "Configured Emacs";
      buildInputs = with pkgs; [
        emacs-unstable-pgtk
        gcc
      
        # used by emacs
        ripgrep

        # used by emacs for c++ development
        clang
        lldb
        clang-tools
        cmakeWithGui
        ccls
        gdb
        semgrep
        python3

        # used by emacs for nix development
        nixd

        # fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        liberation_ttf
        fira-code
        fira-code-symbols
        mplus-outline-fonts.githubRelease
        dina-font
        cantarell-fonts
        #    all-the-icons
        emacs-all-the-icons-fonts
        
      ] # nerd-fonts
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
    };
      
  in{
  
    emacs-init-el = ./init.el;
    emacs-early-init-el = ./early-init.el;

    configured-emacs = with pkgs; stdenv.mkDerivation emacs-fields;
    devShells.x86_64-linux.default = pkgs.mkShell emacs-fields;
    };

}
