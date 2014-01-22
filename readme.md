This repo contains some useful plugins for oh-my-zsh.

# Plugins

## nginx

It defines `en` and `dis` commands for enabling/disabling sites.
It also has completition for these actions. It completes the argument from listing the sites-available (when `en` is used) and the sites-enabled (when `dis` is used).

It also defines the `vhost` command, which can generate virtualhost config files based on a template.
This template can be easily customized setting the `NGINX_VHOST_TEMPLATE` variable in your `.zshrc` to point to your own template file, or you can set the template with the `-t` option. The script will first look in the `plugins/nginx/templates` folder, if the file not found there, it checks if the given template exists, then if it's not, falls back to the default symfony2 template.
Inside that template you can use `user, vhost and pool_port` variables like this: `root /home/{user}/www/{vhost}/web;`
The `pool_port` is for php-fpm pools. It is calculated by adding 10000 to the user's id. You should have a pool listening on this port.
The default template is for a Symfony 2 application in dev environment, because 9 out of 10 times that's what I need.
The `vhost` command accepts a few arguments, type `vhost -h` to display help.
Here is the current output:

```bash
mikka :: ~ » vhost -h
Usage: vhost [options] [vhost_name]

Options
  -l   Lists enabled vhosts
  -u   Sets the user - defaults to the current user (mikka)
  -t   Sets the template
  -n   Does not enable the generated vhost
  -w   Write the vhost to the /etc/hosts file pointing to 127.0.0.1 (writes it at the end of the first line actually)
  -h   Get this help message
```

### Dependencies

There are no dependencies.

### Example

```bash
vhost -nw -u USER_NAME_HERE VHOST_NAME_HERE
vhost -wt plain_php VHOST_NAME_HERE
```

## php-fpm

This plugin can generate a pool configuration file for a given user based on a template.
This template can be easily customized setting the `FPM_POOL_TEMPLATE` variable in your `.zshrc` to point to your own template file.
Inside that template you can use `user, group and pool_port` variables like this: `listen = 127.0.0.1:{pool_port}`
The `pool_port` is calculated by adding 10000 to the user's id. The `group` is the first group of the user's groups.

If `pool` is called without aruments, it generates the pool for the current user.
This plugin completes the arguments from the users' list.

### Dependencies

There are no dependencies.

### Example

```bash
pool USER_NAME_HERE
```

## lesscss

This plugin contains one command: `watchless`. It watches recursively in a directory for changes of .less files and compiles them to .css files.
Basics taken from http://www.ravelrumba.com/blog/watch-compile-less-command-line/comment-page-1/#comment-2464
If you want to output minified css, pass the `-x` option, and it will pass it to `lessc`.
If you want to watch all of the less files, but compile just one if any of the watched files changed, use the `-c compile_this.less` option. This option is very useful if you have multiple less files for variables, for mixins or for defining the look of separate parts of your app, and you have one less file combining the others, like twitter bootstrap does. If that's the case, you don't want to compile all less files to css, just the main one, but you may want to watch for the changes made to the others too.
Here is the current output of `watchless -h`:
```bash
mikka :: ~ » watchless -h
Usage: watchless [options]

Options
  -x   Compiles less files into minified css files
  -c   Watch all files but compile only the one given here
  -h   Get this help message
```

### Dependencies

This plugin requires `watchr` to be installed. Instructions can be found [here](https://github.com/mynyml/watchr)

### Example

cd in your project's directory, then run `watchless`

```bash
watchless
# or
watchless -x
# or
watchless -xc app.less
```

## bower

[bower](https://github.com/twitter/bower) is a package manager for the web.
This plugin provides some aliases and completitions for this great tool.

### Aliases

* `bi`: installs a package (`bower install`)
* `bl`: lists installed packages (`bower list`)
* `bs`: searches for packages (`bower search`)
* `bu`: updates packages (`bower update`)

### Completition

It completes the basic commands for bower. It uses the `bower help` command to achieve this, not a burned-in list of commands.
It also provides completition for bower install, uses the output of bower search. It takes a few seconds for the first time (in the session), but then the output of `bower search` is cached, so things then speed up a lot.

### Example

```bash
# to install jquery for example
bi jq<TAB>
```

## Symfony2

This plugin already existed, but I've made some modifications, to make it smarter.

### Aliases

In the meantime, it may have lost some aliases, I'll check on that later.

### Completition

Basically, two things happened:

* it is capable to provide completition on multiple consoles.
* it is capable to provide completition on commands, that require entities as argument

First, it is important, that to run a console command, it isn't absolutely sure you type `app/console`. You may have multiple consoles in multiple applications in the same project.
What can you do? Give info about your consoles to this plugin. Put an array called `SYMFONY_COMPLETE_CONSOLE` in your `.zshrc`, *before* the `plugins=(..)` line.
`app/console` and `./console` will work by default.
For example:
```bash
##
# Symfony plugin config
##
SYMFONY_COMPLETE_CONSOLE=( 
	portal/console # for the portal app in project #1
	admin/console  # for the admin app in project #1
)

plugins=(symfony2)
```

The other thing is much more useful. There are a bunch of commands, that require entities as arguments. For example `doctrine:generate:form`.
Wouldn't it be nice to have completition on entities? Now you have it!
If you have your own command that takes an entity too, you can add it to the list of commands, that this plugin completes entities on.
The default list:
```bash
    doctrine:generate:crud
    doctrine:generate:entities
    doctrine:generate:form
    generate:doctrine:crud
    generate:doctrine:entities
    generate:doctrine:form
```

If you need more commands, than put an array called `SYMFONY_COMPLETE_ENTITIES` in your `.zshrc`, *before* the `plugins=(..)` line.
For example:
```bash
##
# Symfony plugin config
##
SYMFONY_COMPLETE_ENTITIES=( 
    my:own:command
    my:other:command
)

plugins=(symfony2)
```

To build a list of available entities, it uses the `doctrine:mapping:info` command, in the default environment, with the default entity manager, and in debug mode.
It could be a problem to you, if you have explicit mapping configured for each environment you use. If it's a real problem, please open an issue about it, or even better, send me a pull request with the solution. Thanks.

## memcached

This plugin helps you easily flush remote memcached instances and provides some aliases.

### Aliases

For local memcached instances

* `memcst`: starts memcached
* `memcstp`: stops memcached
* `memcsts`: memcached status
* `memcr`: restarts memcached
* `memcfr`: force reloads memcached

### Configuration

Configuration must be done in your `.zshrc` (or in a file that is sourced), *before* the `plugins=(..)` line.
You can configure your memecached init script path, just put a variable called `MEMCACHED_INIT_SCRIPT` holding the script's path. It is `/etc/init.d/memcached` by default.
To be able to flush remote memcached instances (or local of course) create per server config files ([sample here](https://github.com/miklos-martin/oh-my-zsh-plugins/blob/master/memcached/server-config-example/servername)) in `~/.memcached` directory.
You can customize this directory with the `MEMCACHED_SERVERS` variable.

The `memcflush` command does the thing based on these files. Just give it the config file name as the first and only argument. You also have completition for it ;)

### Example
```bash
memcflush myserver
```

==========

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/miklos-martin/oh-my-zsh-plugins/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

