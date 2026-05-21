function _fifc_file_type -d "Figure out file type (txt, json, image, video, pdf, archive, binary)"
    set -l mime (file --mime-type -b "$argv")
    set -l binary 0
    if string match --quiet '*binary*' -- (file --mime -b -L "$argv")
        set binary 1
    end

    switch $mime
        case application/{gzip,java-archive,x-{7z-compressed,bzip2,chrome-extension,rar,tar,xar},zip}
            echo archive
            return
        case "image/*"
            echo image
            return
        case "video/*"
            echo video
            return
        case application/pdf
            echo pdf
            return
        case application/json
            echo json
            return
    end

    if test $binary = 1
        echo binary
    else
        echo txt
    end
end
