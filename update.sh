#!env sh

echo "updating config ..."
git commit -am "."
git push
cd ../nixos-cfg
nix flake update emacs-cfg
git commit -am "emacs-cfg update"
nh home switch .
cd ../emacs.d
echo "done!"
