: ${NGINX_DIR:=/etc/nginx}

# nginx basic completition

_nginx_get_en_command_list () {
    ls -a $NGINX_DIR/sites-available | awk '/^[a-z][a-z.-]+$/ { print $1 }'
}

_nginx_get_dis_command_list () {
    ls -a $NGINX_DIR/sites-enabled | awk '/^[a-z][a-z.-]+$/ { print $1 }'
}

_nginx_en () {
   compadd `_nginx_get_en_command_list`
}

_nginx_dis () {
   compadd `_nginx_get_dis_command_list`
}

if [ $use_sudo -eq 1 ]; then
    sudo="sudo"
else
    sudo=""
fi

# Enabling a site
en () {
    if [ ! $1 ]; then
        echo "\033[337;41m\n\tKötelező megadni a virtualhost nevét!\n\033[0m";
        return
    fi
    
    if [ ! -e $NGINX_DIR/sites-available/$1 ]; then
        echo "\033[31m$1\033[0m nem létezik";
        return
    fi

    if [ ! -e $NGINX_DIR/sites-enabled/$1 ]; then
  	    $sudo ln -s $NGINX_DIR/sites-available/$1 $NGINX_DIR/sites-enabled/$1;
	    if [ -e /etc/nginx/sites-enabled/$1 ]; then
        	echo "\033[32m$1\033[0m sikeresen engedélyezve";
        else
            echo "\033[31m$1\033[0m engedélyezésekor hiba lépett fel";
        fi
    else
        echo "\033[31m$1\033[0m már engedélyezve van";
    fi
}
compdef _nginx_en en

# Disabling a site
dis () {
    if [ ! $1 ]; then
        echo "\033[337;41m\n\tKötelező megadni a virtualhost nevét!\n\033[0m";
        return
    fi

    if [ ! -e $NGINX_DIR/sites-enabled/$1 ]; then
        echo "\033[31m$1\033[0m nem létezik";
    else
	    $sudo rm -f $NGINX_DIR/sites-enabled/$1;
	    if [ ! -e $NGINX_DIR/sites-enabled/$1 ]; then
        	echo "\033[32m$1\033[0m sikeresen letiltva";
        else
            echo "\033[31m$1\033[0m letiltásakor hiba lépett fel";
        fi
    fi
}
compdef _nginx_dis dis

# Restarting nginx
nres () {
    service nginx restart   
}

# Completition of vhost
_nginx_get_possible_vhost_list () {
    ls -a $HOME/www | awk '/^[^.][a-z0-9._]+$/ { print $1 }'
}

_nginx_vhost () {
   compadd `_nginx_get_possible_vhost_list`
}

# Parsing arguments
vhost () {
    while getopts ":lu:nh" Option
    do
      case $Option in
        l ) ls $NGINX_DIR/sites-enabled; return ;;
        u ) user=$OPTARG; shift 2 ;;
        n ) enable=0; shift 1 ;;
        h ) _vhost_usage; return ;;
#       * ) _vhost_usage; return ;; # Default.
      esac
    done
    
    : ${user:=$USER}
    : ${enable:=1}
    
    if [ ! $1 ]; then
        echo "\033[337;41m\nThe name of the vhost is required!\n\033[0m"
        return
    fi
    
    _generate $1 $user $enable
}
compdef _nginx_vhost vhost

_vhost_usage () {
    echo "Usage: vhost [options] [vhost_name]"
    echo
    echo "Options"
    echo "  -l   Lists enabled vhosts"
    echo "  -u   Sets the user"
    echo "  -n   Does not enable the generated vhost"
    echo "  -h   Get this help message"
    return
}

# Generate config file
_generate () {
    user=$(cat /etc/passwd | grep $2 | awk -F : '{print $1 }')
    
    if [ ! $user ]; then
      echo "User \033[31m$2\033[0m doesn't have an account on \033[33m$HOST\033[0m"
      return
    fi

    echo "Generating \033[32m$1\033[0m vhost for \033[33m$user\033[0m user"
        
    user_id=$(cat /etc/passwd | grep $2 | awk -F : '{print $3 }')
    pool_id=1$user_id
    
    conf=$(sed -e 's/{vhost}/'$1'/g' -e 's/{user}/'$user'/g' -e 's/{pool_id}/'$pool_id'/g' $ZSH/plugins/nginx/templates/symfony2_vhost)
    
    echo $conf > $1.tmp
    $sudo mv $1.tmp $NGINX_DIR/sites-available/$1
    
    if [ $3 -eq 1 ]; then
        en $1
    fi
}
