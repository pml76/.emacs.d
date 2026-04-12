{
  description = "Configurated Emacs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
  };

  outputs = { self, nixpkgs, emacs-overlay, rust-overlay }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [ (import emacs-overlay) rust-overlay.overlays.default ];
    };
    emacs-additional-packages = with pkgs; [
      # gcc
      
      # used by emacs
      ripgrep

      # used to handle rust projects
      rust-bin.stable.latest.default
      rust-bin.stable.latest.rust-analyzer
      
      
      # used by emacs for c++ development
      clang
      ninja
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
    ++ builtins.filter
      lib.attrsets.isDerivation
      (builtins.attrValues pkgs.nerd-fonts);  
  in {
  
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
