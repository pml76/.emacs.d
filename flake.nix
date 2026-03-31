{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
  
    emacs-init-el = ./init.el;
    emacs-early-init-el = ./early-init.el;

  };
}
