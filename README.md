# schulwiki

**Under construction!**

Customized dokuwiki server including (adapted) plugins, bootstrap3 template and a skeleton for keeping inventory and documentation inside a school environment.

Tested on current LMDE4.

## installation

    sudo schulwiki pkg
    sudo schulwiki repo     foo
    sudo schulwiki server   foo   12345
    sudo schulwiki sync     foo
    sudo schulwiki index    foo
    sudo schulwiki info     foo

## credentials

User    | Password
------- | -------------
`admin` | `admin`

## help

    $ schulwiki help
    USAGE
        schulwiki COMMAND
        schulwiki COMMAND NAME
        schulwiki COMMAND NAME ARG

    COMMAND

        db NAME [TABLE]
            Show information about a struct db.

        help
            Show this help.

        index NAME
            Like 'reload' but also refresh wiki search index.

        info NAME
            Show information about a wiki.

        list
            List all existing wikis.

        php
            Print php.ini for max upload size to STDOUT.

        pkg
            Install nginx, php and php stuff for Debian distro.

        reload NAME
            Reload wiki and restart services.

        repo NAME
            Create the repository for a wiki to sync from.

        server NAME PORT
            Create http server configuration if not existing.

        sync NAME
            Sync from repo to running wiki.
