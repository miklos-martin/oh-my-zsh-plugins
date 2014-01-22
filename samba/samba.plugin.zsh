: ${SAMBA_SERVERS:=~/.samba}
: ${SAMBA_DEFAULT_USERNAME:=$USER}
: ${SAMBA_DEFAULT_UID:=1000}
: ${SAMBA_DEFAULT_GID:=1000}
: ${SAMBA_DEFAULT_FILE_MODE:=0755}
: ${SAMBA_DEFAULT_DIR_MODE:=0755}

# Mount a remote samba share
smount () {

    if [[ -z "$SAMBA_SERVERS" ]]; then
        _error "Config not found"
        return;
    fi

    typeset server=$1;
    typeset host;
    typeset sharedDirectory;
    typeset mountPoint;
    typeset username=$SAMBA_DEFAULT_USERNAME;
    typeset uid=$SAMBA_DEFAULT_UID;
    typeset gid=$SAMBA_DEFAULT_GID;
    typeset fileMode=$SAMBA_DEFAULT_FILE_MODE;
    typeset dirMode=$SAMBA_DEFAULT_DIR_MODE;

    if [[ -r $SAMBA_SERVERS/$server ]]; then
        source $SAMBA_SERVERS/$server
    else
        _error "Config for server '$server' doesn't exist, or isn't readable!";
        return;
    fi
    
    if [[ -z "$host" ]]; then
        _error "Config for server $server doesn't contain a host!";
        return;
    fi
    
    if [[ -z "$sharedDirectory" ]]; then
        _error "Config for server $server doesn't contain a shared directory!";
        return;
    fi
    
    if [[ -z "$mountPoint" ]]; then
        _error "Config for server $server doesn't contain a mount point!";
        return;
    fi
    
    if [[ -e $( which -p sudo 2>&1 ) ]]; then
        sudo="sudo"
    else
        sudo=""
    fi
    
    $sudo mkdir -p $mountPoint
    $sudo mount -t cifs -o username=$username,uid=$uid,gid=$gid,file_mode=$fileMode,dir_mode=$dirMode //$host/$sharedDirectory $mountPoint
}

compdef _samba_mount smount

_samba_get_server_list () {
    [ ! -z "$SAMBA_SERVERS" ] && [ -d $SAMBA_SERVERS ] && ls $SAMBA_SERVERS
}

_samba_mount () {
    compadd `_samba_get_server_list`
}

_error () {
    echo "\033[337;41m\n$1\n\033[0m";
    return 1
}

