# Create directory and jump into it
function mkcd
    mkdir -p $argv[1]
    and cd $argv[1]
end

function git-clone-and-cd
    git clone $argv[1] $argv[2]
    cd $(test -n "$argv[2]"; and echo $argv[2]; or echo $argv[1] | sed 's/^.*\///;s/\.git//')
end

function git-clone-and-cd-fast
    git clone --depth 1 --single-branch --filter=blob:none $argv[1] $argv[2]
    cd $(test -n "$argv[2]"; and echo $argv[2]; or echo $argv[1] | sed 's/^.*\///;s/\.git//')
end

# Turn ... into cd ../../
function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add dotdot --regex '^\.\.+$' --function multicd

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")

    if test -n "$KITTY_PID"
        kitty @ set-spacing padding=0 margin=0
    end

    yazi $argv --cwd-file="$tmp"

    if test -n "$KITTY_PID"
        kitty @ set-spacing padding=24 margin=0
    end

    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        # Use the normal cd here as it is actually zoxide and then zoxide remembers it
        cd -- "$cwd"
    end

    rm -f -- "$tmp"
end

function gitm
    # Check if we're in a Git repository
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Not in a Git repository."
        return 1
    end

    # Try to determine the primary branch (main or master)
    set branch (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

    # If neither main nor master is found, default to master
    if test -z "$branch"
        set branch master
    end

    # Checkout the primary branch
    git checkout $branch
end

function __queryPathPartsWithMaybeFile
    set argsLength (count $argv)

    if test $argsLength -eq 1
        zoxide query -l $argv
        return 0
    end

    set last_argument $argv[-1]
    set arguments_without_last $argv[1..(math (count $argv) - 1)]

    set query_results_directory (zoxide query -l $argv)
    set query_results_file_base (zoxide query -l $arguments_without_last)

    set query_results_file
    for base_path in $query_results_file_base
        set --append query_results_file (fd -L --max-depth=5 --type=file --glob  "*$last_argument*" "$base_path")
    end

	# Exclude dirs which are part of the files
    set filtered_dirs
	for base in $query_results_file_base $query_results_directory
		set should_add true

		for found_file in $query_results_file 
			if string match --quiet "$base*" (dirname $found_file)
				set should_add false
				break
			end
		end

		if test "$should_add" = true
			set --append filtered_dirs $base
		end
	end


    set all_items $query_results_file $filtered_dirs
    printf '%s\n' $all_items
end

function cdn
    set argsLength (count $argv)

    if test $argsLength -eq 0
        echo "Usage: cdn <path_parts...> <file?>"
        return 1
    end

    set results (__queryPathPartsWithMaybeFile $argv)
    set results_count (count $results)

    if test $results_count -eq 0
        echo "No matches found"
        return 1
    end

    set target

    if test $results_count -eq 1
        set target $results[1]
    else
        set colored_results
        for item in $results
            if test -f $item
                set filename (basename $item)
                set dirname (dirname $item)
                set --append colored_results (printf '%s/%s%s' (set_color brblack)$dirname(set_color blue) $filename(set_color normal))
            else if test -d $item
                set dirname (dirname $item)
                set basename (basename $item)
                set --append colored_results (printf '%s/%s%s' (set_color brblack)$dirname(set_color yellow) $basename(set_color normal))
            end
        end

        set target (printf '%s\n' $colored_results | fzf --ansi --prompt="Select target: " | string replace -r '^.* (.+)$' '$1')
    end

    if test -z "$target"
        echo "No selection made"
        return 1
    end

    if test -f $target
        set target_dir (dirname $target)
        set target_file (basename $target)
        cd $target_dir && nvim $target_file
    else if test -d $target
        cd $target && nvim .
    else
        echo "Target not found or inaccessible: $target"
        return 1
    end
end


function cdc
    cd $argv && code .
end


function cdz
    cd $argv && zeditor .
end

function commit_empty
    # Check if email argument is provided
    if test (count $argv) -eq 0
        echo "Usage: commit_empty <email>"
        set_color grey
        echo "Example: commit_empty user@example.com"
        return 1
    end

    set email $argv[1]

    # Create empty commit with specified email
    git -c user.email="$email" commit --allow-empty -m "empty commit - VDawg"

    if test $status -eq 0
        set_color green
        echo "✧ Empty commit created successfully with email: $email (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"
    else
        set_color red
        echo "Failed to create commit"
        return 1
    end
end
