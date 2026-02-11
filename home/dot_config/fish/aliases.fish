abbr nrd "nr dev"
abbr nrb "pnpm build"

abbr icat "kitty +kitten icat"
abbr c. "code ."
abbr n. "nvim ."
abbr h. "nvim ~/.config/hypr"

abbr mvd "mullvad disconnect"
abbr mvc "mullvad connect"
abbr mvs "mullvad status"

abbr lsg "ls | rg "

abbr g git
abbr gitc git-clone-and-cd
abbr gitcf git-clone-and-cd-fast
abbr gitf "git add -A && git commit -m 'commit save point' && git push"
abbr gitp "git pull"

abbr nixs nix-shell

abbr frb flutter_rust_bridge_codegen

abbr sepoku "systemctl poweroff"

abbr jd "just dev"

# No need to install the whole Postgres package for that
alias psql="nix shell nixpkgs#postgresql --command psql"
