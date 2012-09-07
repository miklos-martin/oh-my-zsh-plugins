# taken from here:
# http://www.ravelrumba.com/blog/watch-compile-less-command-line/comment-page-1/#comment-2464
# Requires watchr: https://github.com/mynyml/watchr

watchless () {
    compressed=0;
    
    while getopts ":xh" option
    do
      case $option in
        x ) compressed=1 ;;
        h ) _watchless_usage; return ;;
      esac
    done

    if [ $compressed -eq 1 ]; then
        x=' -x'
    else
        x=''
    fi
    
    watchr -e 'watch(".*\.less$") { |f| system("lessc #{f[0]} > $(echo #{f[0]} | cut -d\. -f1).css'$x' && echo \"#{f[0]} > $(echo #{f[0]} | cut -d\. -f1).css\" ") }'
}

_watchless_usage () {
    echo "Usage: watchless [options]"
    echo
    echo "Options"
    echo "  -x   Compiles less files into minified css files"
    echo "  -h   Get this help message"
    return
}
