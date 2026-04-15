#!env sh

echo "updating emacs config ..."
git commit -am "."
git push
cd ../nixos-cfg
nix flake update emacs-cfg
git commit -am "emacs-cfg update"
sh update-home.sh
cd ../emacs.d
echo "done!"
