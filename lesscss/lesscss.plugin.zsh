# taken from here:
# http://www.ravelrumba.com/blog/watch-compile-less-command-line/comment-page-1/#comment-2464
# Requires watchr: https://github.com/mynyml/watchr

watchless () {
    watchr -e 'watch(".*\.less$") { |f| system("lessc #{f[0]} > $(echo #{f[0]} | cut -d\. -f1).css && echo \"#{f[0]} > $(echo #{f[0]} | cut -d\. -f1).css\" ") }'
}
