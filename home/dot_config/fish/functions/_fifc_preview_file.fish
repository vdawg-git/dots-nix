function _fifc_preview_file -d "Preview the selected file with upstream-style MIME and extension handling"
    set -l location "$fifc_candidate"
    set -l extension (path extension "$location" | string lower | string replace -r '^\.' '')
    set -l mime_type (file --mime-type -b "$location")

    switch $mime_type
        case 'text/*'
            _fifc_clear_graphics
            switch $extension
                case md
                    if type -q glow
                        glow --style=auto "$location"
                    else if type -q bat
                        bat -p --color=always "$location"
                    else
                        cat "$location"
                    end
                case htm html
                    if type -q w3m
                        w3m -T text/html -dump "$location"
                    else
                        _fifc_preview_file_default "$location"
                    end
                case '*'
                    if type -q bat
                        bat -p --color=always "$location"
                    else
                        cat "$location"
                    end
            end
            return
        case application/json
            _fifc_clear_graphics
            if type -q bat; and type -q jq
                bat -p --color=always "$location" | jq
            else if type -q bat
                bat -p --color=always "$location"
            else
                cat "$location"
            end
            return
        case inode/directory
            _fifc_clear_graphics
            if type -q eza
                eza -T -L 2 "$location"
            else
                _fifc_preview_file_default "$location"
            end
            return
        case inode/symlink
            _fifc_clear_graphics
            set -l target (readlink "$location")
            if string match -rq '^/nix/store/[a-z0-9]{32}-[^/]+' -- "$target"
                set -l nix_bits (string match -r '^/nix/store/([a-z0-9]{32}-[^/]+)(/.*)?$' -- "$target")
                echo 'Symlink to a nix store path'
                echo "hash: $nix_bits[2]"
                echo 'place: /nix/store'
                if test -n "$nix_bits[3]"
                    echo "path: "(string trim -c '/' -- "$nix_bits[3]")
                else
                    echo 'path: <root of hash>'
                end
            else
                echo "Symbolic link to: $target"
            end
            return
        case application/x-executable application/x-pie-executable application/x-sharedlib
            _fifc_clear_graphics
            if type -q readelf
                readelf --wide --demangle=auto --all "$location"
            else
                _fifc_preview_file_default "$location"
            end
            return
        case application/x-x509-ca-cert
            _fifc_clear_graphics
            if type -q openssl
                openssl x509 -text -noout -in "$location"
            else
                _fifc_preview_file_default "$location"
            end
            return
        case 'image/*'
            if _fifc_preview_graphic "$location"
                type -q mediainfo; and mediainfo "$location"
            else if type -q mediainfo
                _fifc_clear_graphics
                mediainfo "$location"
            else if type -q exiftool
                _fifc_clear_graphics
                exiftool "$location"
            else
                _fifc_preview_file_default "$location"
            end
            return
        case 'video/*'
            if type -q ffmpegthumbnailer
                set -l thumbnail (mktemp -t fifc-video-preview.XXXXXX.jpg)
                ffmpegthumbnailer -i "$location" -o "$thumbnail" -s 1200 >/dev/null 2>&1
                if test -f "$thumbnail"; and _fifc_preview_graphic "$thumbnail"
                    type -q mediainfo; and mediainfo "$location"
                else if type -q mediainfo
                    _fifc_clear_graphics
                    mediainfo "$location"
                else if type -q exiftool
                    _fifc_clear_graphics
                    exiftool "$location"
                else
                    _fifc_preview_file_default "$location"
                end
                rm -f "$thumbnail"
            else if type -q mediainfo
                _fifc_clear_graphics
                mediainfo "$location"
            else if type -q exiftool
                _fifc_clear_graphics
                exiftool "$location"
            else
                _fifc_preview_file_default "$location"
            end
            return
        case application/pdf
            if type -q pdftoppm
                set -l preview_base (mktemp -t fifc-pdf-preview.XXXXXX)
                pdftoppm -jpeg -f 1 -singlefile "$location" "$preview_base" >/dev/null 2>&1
                if test -f "$preview_base.jpg"; and _fifc_preview_graphic "$preview_base.jpg"
                    type -q mediainfo; and mediainfo "$location"
                else if type -q pdftotext
                    _fifc_clear_graphics
                    pdftotext -l 10 -nopgbrk "$location" - 2>/dev/null
                else
                    _fifc_preview_file_default "$location"
                end
                rm -f "$preview_base.jpg"
            else if type -q pdftotext
                _fifc_clear_graphics
                pdftotext -l 10 -nopgbrk "$location" - 2>/dev/null
            else
                _fifc_preview_file_default "$location"
            end
            return
    end

    switch $extension
        case a ace alz arc arj bz bz2 cab cpio deb gz jar lha lz lzh lzma lzo rpm rz t7z tar tbz tbz2 tgz tlz txz tz tzo war xpi xz z zip rar
            _fifc_clear_graphics
            if type -q atool
                atool --list -- "$location"
            else
                _fifc_preview_file_default "$location"
            end
        case 7z
            _fifc_clear_graphics
            if type -q 7z
                7z l -p -- "$location"
            else
                _fifc_preview_file_default "$location"
            end
        case iso
            _fifc_clear_graphics
            if type -q iso-info
                iso-info --no-header -l "$location"
            else
                _fifc_preview_file_default "$location"
            end
        case odt ods odp sxw
            _fifc_clear_graphics
            if type -q odt2txt
                odt2txt "$location"
            else
                _fifc_preview_file_default "$location"
            end
        case doc
            _fifc_clear_graphics
            if type -q catdoc
                catdoc "$location"
            else
                _fifc_preview_file_default "$location"
            end
        case xls xlsx
            _fifc_clear_graphics
            if type -q ssconvert; and type -q bat
                ssconvert --export-type=Gnumeric_stf:stf_csv "$location" fd://1 | bat --language=csv --color=always
            else
                _fifc_preview_file_default "$location"
            end
        case wav mp3 flac m4a wma ape ac3 oga ogg ogx spx opus asf mka
            _fifc_clear_graphics
            if type -q exiftool
                exiftool "$location"
            else
                _fifc_preview_file_default "$location"
            end
        case '*'
            _fifc_clear_graphics
            if string match --quiet '*binary*' -- (file --mime -b -L "$location")
                if type -q hexyl
                    hexyl $fifc_hexyl_opts "$location"
                else
                    _fifc_preview_file_default "$location"
                end
            else if type -q bat
                bat -p --color=always "$location"
            else
                cat "$location"
            end
    end
end
