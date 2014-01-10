: ${MEMCACHED_INIT_SCRIPT:=/etc/init.d/memcached}

if [[ -e $( which -p sudo 2>&1 ) ]]; then
    sudo="sudo"
else
    sudo=""
fi

# Aliases
alias memcst="$sudo $MEMCACHED_INIT_SCRIPT start"
alias memcstp="$sudo $MEMCACHED_INIT_SCRIPT stop"
alias memcsts="$sudo $MEMCACHED_INIT_SCRIPT status"
alias memcr="$sudo $MEMCACHED_INIT_SCRIPT restart"
alias memcfr="$sudo $MEMCACHED_INIT_SCRIPT force-reload"
