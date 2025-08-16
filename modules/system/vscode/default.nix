{ pkgs, lib, ... }:

# https://stackoverflow.com/questions/68523367/in-nixpkgs-how-do-i-override-files-of-a-package-without-recompilation

let
  filesToApply = [
    "vscode.css" # Nice rounding
    "gruvbox.css" # Changes some colors (icons get a sepia filter)
  ];

  vscode = pkgs.vscode;

  postBuild = ''
    set -euo pipefail

    workbenchPath="$( ${pkgs.fd}/bin/fd workbench.html $out )"
    echo Found workbenchPath: 
    echo $workbenchPath

    if [ -z $workbenchPath ]; then
      echo "No workspace.html found. Cannot modify CSS. Aborting.."
      exit 1
    fi


    # install -v "${vscode}"/"$workbenchPath" "$out"/"$workbenchPatha"
    # sed -i -e 's/usage:/USAGE:/g' "$out"/share/git/contrib/fast-import/git-import.sh
  '';

in
pkgs.symlinkJoin {
  inherit (vscode)
    name
    pname
    version
    meta
    ;

  paths = [ vscode ];
  inherit postBuild;
}
