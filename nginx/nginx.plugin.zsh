# nginx basic command completition

_nginx_get_en_command_list () {
    ls -a /etc/nginx/sites-available | awk '/^[a-z][a-z.-]+$/ { print $1 }'
}

_nginx_get_dis_command_list () {
    ls -a /etc/nginx/sites-enabled | awk '/^[a-z][a-z.-]+$/ { print $1 }'
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
    
    if [ ! -e /etc/nginx/sites-available/$1 ]; then
        echo "\033[31m$1\033[0m nem létezik";
        return
    fi

    if [ ! -e /etc/nginx/sites-enabled/$1 ]; then
  	    $sudo ln -s /etc/nginx/sites-available/$1 /etc/nginx/sites-enabled/$1;
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

    if [ ! -e /etc/nginx/sites-enabled/$1 ]; then
        echo "\033[31m$1\033[0m nem létezik";
    else
	    $sudo rm -f /etc/nginx/sites-enabled/$1;
	    if [ ! -e /etc/nginx/sites-enabled/$1 ]; then
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
