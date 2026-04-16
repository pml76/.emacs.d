{
  description = "Configurated Emacs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
  };

  outputs = { self, nixpkgs, emacs-overlay, claude-code }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config = { allowUnfree = true; };
      overlays = [ (import emacs-overlay) ];
    };

    emacs-additional-packages = with pkgs; [
      # gcc
      
      # used by emacs
      ripgrep

      # used to handle rust projects
      rustup
      
      
      # used by emacs for c++ development
      clang
      ninja
      gnumake
      libtool
      lldb
      clang-tools
      cmakeWithGui
      gdb
      semgrep
      python3
      
      # used by emacs for nix development
      nixd

      # used by emacs for cmake development
      cmake-language-server

      #claude code for testing ...
      claude-code.packages.${stdenv.hostPlatform.system}.claude-code
      
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
      jetbrains-mono

      # some stand fonts
      corefonts
      vista-fonts

      source-serif
      source-sans
      source-code-pro
        
    ] # nerd-fonts
    ++ builtins.filter
      lib.attrsets.isDerivation
      (builtins.attrValues pkgs.nerd-fonts);  
  in {

    claude-code = claude-code;
    
    emacs-init-el = ./init.el;
    emacs-early-init-el = ./early-init.el;

    emacs = pkgs.emacs-unstable-pgtk;

    emacs-additional-packages = emacs-additional-packages;
    
    devShells.x86_64-linux.default = pkgs.mkShell {

      buildInputs = with pkgs; [
        emacs-unstable-pgtk ]
      ++ emacs-additional-packages;
    };
  };

}
