# schulwiki.sh

 Bash4+ wrapper skript for customized dokuwiki server in school environment

## INFO

 Tested on LMDE4 (Debian Buster).
 Before installing please check/adapt `config` at the top of `schulwiki.sh`.

## USAGE

    schulwiki COMMAND [ARG]

## COMMAND

    db [TABLE]
        Show information about a struct db.

    help 
        Show this help.

    index 
        Like 'reload' but also refresh wiki search index.

    info 
        Show information about a wiki.

    php 
        Write php.ini for max upload size.

    pkg 
        Install nginx, php and stuff for Debian distro.

    reload 
        Reload wiki and restart services.

    repo 
        Create the repository for a wiki to sync from.

    server 
        Create http server configuration if not existing.

    sync 
        Sync from repo to running wiki.

## CREDENTIALS

 User    | Password
 ------- | -------------
 `admin` | `admin`

## INSTALLATION

    tmpdir=$( mktemp -d ) && cd $tmpdir
    git clone https://github.com/grg8/schulwiki schulwiki
    sudo cp schulwiki/schulwiki.sh /usr/local/bin/schulwiki
    schulwiki help                # shows this document
    sudo schulwiki pkg
    sudo schulwiki repo
    sudo schulwiki server
    sudo schulwiki php
    sudo schulwiki sync
    sudo schulwiki reload
    sudo schulwiki index
    schulwiki info
    schulwiki db

