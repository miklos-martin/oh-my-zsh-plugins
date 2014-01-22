: ${MEMCACHED_INIT_SCRIPT:=/etc/init.d/memcached}
: ${MEMCACHED_SERVERS:=~/.memcached}

# Flush a remote memcached server
mcf () {
    
    if [[ -z "$MEMCACHED_SERVERS" ]]; then
        _error "Config not found"
        return;
    fi

    typeset server=$1;
    typeset host;
    typeset ports;

    if [[ -r $MEMCACHED_SERVERS/$server ]]; then
        source $MEMCACHED_SERVERS/$server
    else
        _error "Config for server '$server' doesn't exist, or isn't readable!";
        return;
    fi
    
    if [[ -z "$host" ]]; then
        _error "Config for server $server doesn't contain a host!";
        return;
    fi
    
    if [[ -z "$ports" ]]; then
        _error "Config for server $server doesn't contain any ports!";
        return;
    fi
    
    for port in $ports; do
        (echo "flush_all" | nc $host $port 2>/dev/null;) || _error "Host '$host' or port '$port' is not valid"
    done
}

compdef _memcached_flush mcf

_memcached_get_server_list () {
    [ ! -z "$MEMCACHED_SERVERS" ] && [ -d $MEMCACHED_SERVERS ] && ls $MEMCACHED_SERVERS
}

_memcached_flush () {
    compadd `_memcached_get_server_list`
}

_error () {
    echo "\033[337;41m\n$1\n\033[0m";
    return 1
}

if [[ -e $( which -p sudo 2>&1 ) ]]; then
    sudo="sudo"
else
    sudo=""
fi

# Aliases
alias mcst="$sudo $MEMCACHED_INIT_SCRIPT start"
alias mcstp="$sudo $MEMCACHED_INIT_SCRIPT stop"
alias mcsts="$sudo $MEMCACHED_INIT_SCRIPT status"
alias mcr="$sudo $MEMCACHED_INIT_SCRIPT restart"
alias mcfr="$sudo $MEMCACHED_INIT_SCRIPT force-reload"
