# schulwiki

Under construction!

Tested on current LMDE4.

## installation

    sudo schulwiki pkg
    sudo schulwiki repo     foo
    sudo schulwiki server   foo   12345
    sudo schulwiki sync     foo
    sudo schulwiki index    foo
    sudo schulwiki info     foo

## help

    $ schulwiki help
    USAGE
        schulwiki COMMAND
        schulwiki COMMAND ARG

    COMMAND

        help
            Show this help.

        index NAME
            Like 'reload' but also refresh wiki search index.

        info NAME
            Show information about a wiki.

        list
            List all existing wikis.

        pkg
            Install nginx, php and php stuff for Debian distro.

        reload NAME
            Reload wiki and restart services.

        repo NAME
            Create the repository for a wiki to sync from.

        server NAME PORT
            Print server config to STDOUT.

        sync NAME
            Sync from repo to running wiki.


