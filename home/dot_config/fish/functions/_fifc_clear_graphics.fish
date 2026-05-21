function _fifc_clear_graphics -d "Clear terminal graphics in preview panes when supported"
    if set -q KITTY_WINDOW_ID; or set -q GHOSTTY_RESOURCES_DIR; or test "$TERM_PROGRAM" = ghostty
        printf '\e[2J\e[H'
        printf '\e_Ga=d,d=a,q=2\e\\'
    end
end
