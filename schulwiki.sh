#!/bin/bash
#---
# file      : schulwiki.sh
# date      : 2021-12-14
# version   : 0.0.14
# info      : customized dokuwiki wrapper script
#---

##
schulwiki() {

    ### configuration (defaults)
    conf() {

        conf_usage="${nt}schulwiki COMMAND [ARG]"

        conf_opt_=(
            [db]='[TABLE]'"${ntt}"'Show information about a struct db.'
            [help]="${ntt}"'Show this help.'
            [info]=''"${ntt}"'Show information about a wiki.'
            [reload]=''"${ntt}"'Reload wiki and restart services.'
            [index]=''"${ntt}"'Like '"'"'reload'"'"' but also refresh wiki search index.'
            [php]="${ntt}"'Write php.ini for max upload size.'
            [pkg]="${ntt}"'Install nginx, php and stuff for Debian distro.'
            [repo]=''"${ntt}"'Create the repository for a wiki to sync from.'
            [server]=''"${ntt}"'Create http server configuration if not existing.'
            [sync]=''"${ntt}"'Sync from repo to running wiki.'
        )                                                                       &&

        # default optarg
        conf_opt__=( "help" )                                                   &&

        # default config
        conf_def_=(
            [name]="schulwiki"
            [port]=80
            [root]="/var/www/html"
            [repo]="/opt"
            [server]="/etc/nginx"
            [owner]="www-data"
            [group]="www-data"
            [maxsize]="1000M"
            [dokuwiki]='https://github.com/splitbrain/dokuwiki.git'
            [dokuwiki_branch]='stable'
            [skel]='https://github.com/grg8/schulwiki-skel.git'
            [date]='%y%m%d_%H%M%S'
        )                                                                       &&

        # plugins
        conf_git_plugins_=(
            [addnewpage]='https://github.com/samwilson/dokuwiki-plugin-addnewpage.git'
            [addnewsidebar]='https://github.com/grg8/dokuwiki-plugin-addnewsidebar.git'
            [addnewticket]='https://github.com/grg8/dokuwiki-plugin-addnewticket.git'
            [bootswrapper]='https://github.com/giterlizzi/dokuwiki-plugin-bootswrapper.git'
            [captcha]='https://github.com/splitbrain/dokuwiki-plugin-captcha.git'
            [catlist]='https://github.com/xif-fr/dokuwiki-plugin-catlist.git'
            [custombuttons]='https://github.com/ConX/dokuwiki-plugin-custombuttons.git'
            [discussion]='https://github.com/dokufreaks/plugin-discussion.git'
            [dw2pdf]='https://github.com/splitbrain/dokuwiki-plugin-dw2pdf.git'
            [icons]='https://github.com/giterlizzi/dokuwiki-plugin-icons.git'
            [include]='https://github.com/dokufreaks/plugin-include.git'
            [move]='https://github.com/michitux/dokuwiki-plugin-move.git'
            [newpagetemplate]='https://github.com/turnermm/newpagetemplate.git'
            [nosidebar]='https://github.com/lupo49/dokuwiki-plugin-nosidebar.git'
            [searchindex]='https://github.com/splitbrain/dokuwiki-plugin-searchindex.git'
            [smtp]='https://github.com/splitbrain/dokuwiki-plugin-smtp.git'
            [sqlite]='https://github.com/cosmocode/sqlite.git'
            [struct]='https://github.com/cosmocode/dokuwiki-plugin-struct.git'
            [structjoin]='https://github.com/gkrid/dokuwiki-plugin-structjoin.git'
            [tablewidth]='https://github.com/dwp-forge/tablewidth.git'
            [upgrade]='https://github.com/splitbrain/dokuwiki-plugin-upgrade.git'
            [vshare]='https://github.com/splitbrain/dokuwiki-plugin-vshare.git'
            [wrap]='https://github.com/selfthinker/dokuwiki_plugin_wrap.git'
            [yearbox]='https://github.com/micgro42/yearbox.git'
        )                                                                       &&

        # templates
        conf_git_tpl_=(
            [bootstrap3]='https://github.com/LotarProject/dokuwiki-template-bootstrap3.git'
        )                                                                       &&

        # debian packages
        conf_apt__=(
            csvtool git nginx php sqlite3 vim
            php-apcu php-bcmath php-common php-curl php-fpm php-gd
            php-gettext php-gmp php-imap php-intl php-json php-mbstring
            php-memcache php-mysql php-pear php-pspell php-recode php-sqlite3
            php-tidy php-xml php-xmlrpc
        )                                                                       &&

        : || { err "error at config." ; return 1 ; }

    }                                                                           &&


    ### initialize
    init() {

        init_apt__=( "${conf_apt__[@]}" )                                       &&

        init_date="$( date +"${conf_def_[date]}" )"                             &&
        init_dokuwiki_branch="${conf_def_[dokuwiki_branch]}"                    &&

        init_repo="${conf_def_[repo]}/${conf_def_[name]}"                       &&
        init_repo_=(
            [dokuwiki]="${init_repo}/dokuwiki"
            [plugins]="${init_repo}/plugins"
            [skel]="${init_repo}/skel"
            [tpl]="${init_repo}/tpl"
        )                                                                       &&

        init_dokuwiki="${conf_def_[root]}/${conf_def_[name]}"                   &&
        init_dokuwiki_=(
            [dokuwiki]="${init_dokuwiki}"
            [plugins]="${init_dokuwiki}/lib/plugins"
            [skel]="${init_dokuwiki}"
            [tpl]="${init_dokuwiki}/lib/tpl"
        )                                                                       &&

        init_db="${init_dokuwiki}/data/meta/struct.sqlite3"                     &&

        init_backup="${init_repo}/_backup"                                      &&
        init_backup_sync="${init_backup}/sync"                                  &&
        init_backup_=(
            [attic]="${init_dokuwiki}/data/attic"
            [conf]="${init_dokuwiki}/conf"
            [pages]="${init_dokuwiki}/data/pages"
            [plugins]="${init_dokuwiki}/lib/plugins"
            [tpl]="${init_dokuwiki}/lib/tpl"
            [meta]="${init_dokuwiki}/data/meta"
            [media]="${init_dokuwiki}/data/media"
            [media_meta]="${init_dokuwiki}/data/media_meta"
            [media_attic]="${init_dokuwiki}/data/media_attic"
        )                                                                       &&

        init_server_=(
            [port]="${conf_def_[port]}"
            [conf]="${conf_def_[server]}/sites-available/${conf_def_[name]}.conf"
            [conf_link]="../sites-available/${conf_def_[name]}.conf"
            [conf_enabled]="${conf_def_[server]}/sites-enabled/${conf_def_[name]}.conf"
            [nginx]="${conf_def_[server]}/nginx.conf"
            [owner]="${conf_def_[owner]}"
            [group]="${conf_def_[group]}"
        )                                                                       &&

        : || { err "error at init" ; return 1 ; }

    } &&

    ### options

    opt_db() {
        declare -a  id__=()
        declare     select=
        declare     header=
        #~ declare -a  sid__=()
        declare -a  tid__=()
        if [[ ${#@} -eq 0 ]] ; then
            db__=()
            for i in $( sqlite3 "${init_db}" ".tables" ) ; do
                [[ "${i}" =~ data_(.*) ]] &&
                    db__+=( "${BASH_REMATCH[1]}" )
            done
            printf "%s\n" "${db__[@]}"
        else
            id__=(
                $(
                    sqlite3 "${init_db}" "
                        select id from schemas
                        where tbl like '${1}'
                    "
                )
            ) # 7 8 9

            #~ sid__=( $(
                #~ sqlite3 "${init_db}" "
                    #~ select colref from schema_cols
                    #~ where sid like '${id}'
                #~ "
                #~ )
            #~ )

            tid__=( $(
                sqlite3 "${init_db}" "
                    select tid from schema_cols
                    where sid like '${id__[0]}'
                    order by sort asc;
                "
                )
            )

            for (( i=0,j=1;i<${#tid__[@]};i++,j++ )) ; do
                select="${select},col${j}"
                header="${header},$(
                    sqlite3 "${init_db}" "
                        select label from types
                        where id like '${tid__[${i}]}'
                    "
                )"
            done
            select="${select#,}"
            header="${header#,}"

            printf "%s\n" "${header}"
            sqlite3 -csv "${init_db}" "
                select ${select} from data_${1}
            "
                #~ where id like '${id}'

        fi
    }

    opt_help() {
        printf "%s\n\n" "# schulwiki.sh"                                        &&
        printf " %s\n"                                                          \
            "Bash4+ wrapper skript for customized dokuwiki server in school environment" \
                                                                                &&
        printf "\n"                                                             &&

        printf "%s\n\n" "## INFO"                                               &&
        printf " %s\n"                                                          \
            'Tested on LMDE4 (Debian Buster).'                                  \
            'Before installing please check/adapt `config` at the top of `schulwiki.sh`.' \
                                                                                &&
        printf "\n"                                                             &&

        printf "%s\n" '## USAGE'                                                &&
        printf "%s\n" "${conf_usage}"                                           &&
        printf "\n"                                                             &&

        printf "%s\n\n" '## COMMAND'                                            &&
        {
            printf "%s\n" "${!conf_opt_[@]}"                                    |
            sort                                                                |
            while IFS= read -r line ; do
                printf "    %s %s\n\n"  "${line}" "${conf_opt_[${line}]}"
            done
        }                                                                       &&

        printf "%s\n\n" "## CREDENTIALS"                                        &&
        printf " %s\n"                                                          \
            'User    | Password'                                                \
            '------- | -------------'                                           \
            '`admin` | `admin`'                                                 \
                                                                                &&
        printf "\n"                                                             &&

        printf "%s\n" "## INSTALLATION"                                         &&
        printf "${nt}%s"                                                        \
            'tmpdir=$( mktemp -d ) && cd $tmpdir'                               \
            'git clone https://github.com/grg8/schulwiki schulwiki'             \
            'sudo cp schulwiki/schulwiki.sh /usr/local/bin/schulwiki'           \
            'schulwiki help                # shows this document'               \
            'sudo schulwiki pkg'                                                \
            'sudo schulwiki repo'                                               \
            'sudo schulwiki server'                                             \
            'sudo schulwiki php'                                                \
            'sudo schulwiki sync'                                               \
            'sudo schulwiki reload'                                             \
            'sudo schulwiki index'                                              \
            'schulwiki info'                                                    \
            'schulwiki db'                                                      \
                                                                                &&
        printf "\n\n"                                                           &&

        : || { err "error at help" ; return 1 ; }

    }

    opt_repo() {
        local dir=                                                              &&
        local repo=                                                             &&
        mkdir -p "${init_repo_[@]}"                                             &&

        # clone dokuwiki
        dir="${init_repo_[dokuwiki]}"                                           &&
        repo="${conf_def_[dokuwiki]}"                                           &&
        if [[ -z "$( ls -A "${dir}" )" ]] ; then
            git clone --branch "${init_dokuwiki_branch}" "${repo}" "${dir}"
        fi                                                                      &&

        # clone skel
        dir="${init_repo_[skel]}"                                               &&
        repo="${conf_def_[skel]}"                                               &&
        if [[ -z "$( ls -A "${dir}" )" ]] ; then
            git clone "${repo}" "${dir}"
        fi                                                                      &&

        # clone plugins
        for i in "${!conf_git_plugins_[@]}" ; do
            dir="${init_repo_[plugins]}/${i}"                                   &&
            repo="${conf_git_plugins_[${i}]}"                                   &&
            [[ -e "${dir}" ]]                                                   ||
                git clone "${repo}" "${dir}"                                    ||
                    return 1
        done                                                                    &&

        # clone templates
        for i in "${!conf_git_tpl_[@]}" ; do
            dir="${init_repo_[tpl]}/${i}"                                       &&
            repo="${conf_git_tpl_[${i}]}"                                       &&
            [[ -e "${dir}" ]]                                                   ||
                git clone "${repo}" "${dir}"                                    ||
                    return 1
        done                                                                    &&

        : || { err "error at repository." ; return 1 ; }

    }

    opt_sync() {
        #~ rsync -avz ${init_sizeonly}

        mkdir -p "${init_dokuwiki_[@]}" "${init_backup_sync}"                   &&

        rsync -avz                                                              \
            --backup-dir "${init_backup_sync}/${init_date}"                     \
            --exclude composer.*                                                \
            --exclude .editorconfig                                             \
            --exclude .git*                                                     \
            --exclude install.php                                               \
            --exclude _test                                                     \
            "${init_repo_[dokuwiki]}/"                                          \
            "${init_dokuwiki_[dokuwiki]}"                                       \
                                                                                &&

        rsync -avz                                                              \
            --backup-dir "${init_backup_sync}/${init_date}"                     \
            --exclude *.git*                                                    \
            "${init_repo_[plugins]}/"                                           \
            "${init_dokuwiki_[plugins]}"                                        \
                                                                                &&

        rsync -avz                                                              \
            --backup-dir "${init_backup_sync}/${init_date}"                     \
            --exclude *.git*                                                    \
            "${init_repo_[tpl]}/"                                               \
            "${init_dokuwiki_[tpl]}"                                            \
                                                                                &&

        rsync -avz                                                              \
            --backup-dir "${init_backup_sync}/${init_date}"                     \
            --exclude *.git*                                                    \
            "${init_repo_[skel]}/"                                              \
            "${init_dokuwiki_[skel]}"                                           \
                                                                                &&

        : || { err "error at sync." ; return 1 ; }

    }

    opt_reload() {
        local og=                                                               &&
        og="${init_server_[owner]}:${init_server_[group]}"                      &&
        touch "${init_dokuwiki}/conf/local.php"                                 &&
        chown -R "${og}" "${init_dokuwiki}"                                     &&
        nginx -t                                                                &&
        systemctl restart "${init_php_[service]}" nginx.service                 &&
        : || { err "Error at reload." ; return 1 ; }
    }

    opt_index() {
        sudo -u "${init_server_[owner]}" "${init_dokuwiki}/bin/indexer.php" -c  &&
        opt_reload                                                              &&
        : || { err "error at index." ; return 1 ; }
    }

    opt_info() {

        {
            printf "%-31s%s\n"  init_date "${init_date}"
            printf "%-31s%s\n"  init_sizeonly "${init_sizeonly}"

            printf "%-31s%s\n"  init_repo "${init_repo}"
            for i in "${!init_repo_[@]}" ; do
                printf "%-31s%s\n"  init_repo_[${i}] "${init_repo_[${i}]}"
            done

            printf "%-31s%s\n"  init_dokuwiki "${init_dokuwiki}"
            printf "%-31s%s\n"  init_dokuwiki_branch "${init_dokuwiki_branch}"
            for i in "${!init_dokuwiki_[@]}" ; do
                printf "%-31s%s\n"  init_dokuwiki_[${i}] "${init_dokuwiki_[${i}]}"
            done

            printf "%-31s%s\n"  init_backup "${init_backup}"
            printf "%-31s%s\n"  init_backup_sync "${init_backup_sync}"
            for i in "${!init_backup_[@]}" ; do
                printf "%-31s%s\n"  init_backup_[${i}] "${init_backup_[${i}]}"
            done

            for i in "${!init_server_[@]}" ; do
                printf "%-31s%s\n"  init_server_[${i}] "${init_server_[${i}]}"
            done

            for i in "${!init_php_[@]}" ; do
                printf "%-31s%s\n"  init_php_[${i}] "${init_php_[${i}]}"
            done

        } | env LC_COLLATE=C sort
        #~ printf "%s\n" init_nginx_server__ "${init_nginx_server__[@]}"

    }

    opt_server() {

        nginx -T  2>&1                                                          |
        while IFS= read -r line ; do
            [[ "${line}" =~ ^${s}**listen${s}+(${d}+)${s}*[\;] ]] &&
            if [[ "${BASH_REMATCH[1]}" == "${init_server_[port]}" ]] ; then
                exit 1
            fi || :
        done                                                                    &&
        : || { err "port ${init_server_[port]} already used" ; return 1 ; }

        [[ ! -e "${init_server_[conf]}" ]]                                      &&
        : || { err "Config ${init_server_[conf]} already existing." ; return 1 ; }

        printf "%s\n" "${init_nginx_server__[@]}" > "${init_server_[conf]}"     &&
        ln -s "${init_server_[conf_link]}" "${init_server_[conf_enabled]}"      &&
        : || { err "error at server config." ; return 1 ; }

    }

    opt_php() {

        if {
            grep -q ^"${s}*upload_max_filesize${s}*=${s}*${init_php_[maxsize]}${s}*"$ \
                "${init_php_[ini]}"                                             &&
            grep -q ^"${s}*post_max_size${s}*=${s}*${init_php_[maxsize]}${s}*"$ \
                "${init_php_[ini]}"                                             &&
            err "${init_php_[ini]} already up to date"
        } ; then
            :
        else
            cp "${init_php_[ini]}" "${init_php_[ini]}.${init_date}"                 &&
            sed -i                                                                  \
                -e "s/^upload_max_filesize = .*/upload_max_filesize = ${init_php_[maxsize]}/"         \
                -e "s/^post_max_size = .*/post_max_size = ${init_php_[maxsize]}/"                     \
                "${init_php_[ini]}"                                                 &&
            printf "%s\n" "New file written: ${init_php_[ini]}" \
                "Original file copied to: ${init_php_[ini]}.${init_date}"           &&

            : || { err "error at creating php config." ; return 1 ; }
        fi
    }

    opt_pkg() {
        apt update                                                              &&
        apt upgrade                                                             &&
        apt-get install "${init_apt__[@]}"                                      &&
        : || { err "could not install prerequisites." ; return 1 ; }
    }

    err() {
        set -- "${@:-unknown error}"
        {
            printf "${0}: aborted: %s\n" "${@}"
            printf "%s\n" "Please try \`schulwiki help\` for usage."
        } 1>&2
    }

    ### declare
    {
        #### aux

        # scalar
        declare -x  line=                                                       &&
        declare -x  port=                                                       &&
        declare -x  i=                                                          &&
        declare -x  nt=                                                         &&
        declare -x  ntt=                                                        &&
        declare -x  d=                                                          &&
        declare -x  s=                                                          &&
        declare -x  ns=                                                         &&
        declare -x  vo=                                                         &&
        declare -x  va=                                                         &&

        #### config

        # scalar
        declare -a  conf_usage=()                                               &&

        # array
        declare -a  conf_apt__=()                                               &&
        declare -a  conf_opt__=()                                               &&

        # hash table
        declare -A  conf_opt_=()                                                &&
        declare -A  conf_def_=()                                                &&
        declare -A  conf_git_plugins_=()                                        &&
        declare -A  conf_git_tpl_=()                                            &&

        #### init

        # scalar
        declare -x  init_date=                                                  &&
        declare -x  init_backup=                                                &&
        declare -x  init_backup_sync=                                           &&
        declare -x  init_dokuwiki=                                              &&
        declare -x  init_dokuwiki_branch=                                       &&
        declare -x  init_repo=                                                  &&

        # array
        declare -a  init_nginx_server__=()                                      &&
        declare -a  init_apt__=()                                               &&

        # hash table
        declare -A  init_backup_=                                               &&
        declare -A  init_dokuwiki_=()                                           &&
        declare -A  init_php_=()                                                &&
        declare -A  init_repo_=()                                               &&
        declare -A  init_server_=()                                             &&
        :

        #### user

        # scalar
        declare -x  user_func=                                                  &&
        declare -x  user_opt=                                                   &&

        : || { err "error at cariable declaration." ; return 1 ; }

    }                                                                           &&

    ### aux regex
    d='[[:digit:]]'                                                             &&
    s='[[:space:]]'                                                             &&
    ns='[^[:space:]]'                                                           &&
    vo='^[[:alpha:]_]([[:alnum:]_-]*[[:alnum:]])?$'                             &&
    va='^[-][-][[:alnum:]_]([[:alnum:]_-]*[[:alnum:]])?$'                       &&

    ### aux seperator
    nt='
    '                                                                           &&
    ntt='
        '                                                                       &&

    ### config
    conf                                                                        &&

    ### opt

    # default optarg
    { [[ ${#@} -ge 1 ]] || set -- "${conf_opt__[@]}" ; }                        &&

    # check if given opt is valid
    [[ "${1}" =~ ${vo} ]]                                                       &&
    [[ "${conf_opt_[${1}]-invalid}" != invalid ]]                               &&
    user_opt="${1}"                                                             &&
    shift                                                                       &&
    : || { err "no such option: ${1}" ; return 1 ; }

    # set user function to run
    user_func="opt_${user_opt}"                                                 &&

    ### init
    init                                                                        &&

    ### conditional init

    if [[ "${user_opt}" =~ server|reload|index|info|php ]] ; then
        # @todo: write out to e.g. phprc at /opt/schulwiki
        init_php_=(
            [service]="$(
                    systemctl list-unit-files   |
                    grep fpm                    |
                    cut -d' ' -f1               || :
                )"
            [socket]="$(
                    find /etc/php -name www.conf -exec \
                    sed -n "s/^listen${s}*=${s}*\(${ns}\+\)/\1/p" '{}' \;
                )"
            [ini]="$( find /etc/php -name php.ini | grep fpm  )"
            [maxsize]="${conf_def_[maxsize]}"
        )                                                                       &&
        : || { err "error at php init." ; return 1 ; }
    fi                                                                          &&

    if [[ "${user_opt}" == server ]] ; then
        [[ "${init_server_[port]}" =~ ^[[:digit:]]+$ ]]                         &&
        [[ "${init_server_[port]}" -le 65535  ]]                                &&
        : || { err "invalid port: ${init_server_[port]}" ; return 1 ; }

        init_nginx_server__=(
            'server {'
            ''
            ' listen '"${init_server_[port]}"';'
            ' server_name 127.0.0.1;'
            ' root '"${init_dokuwiki}"';'
            ''
            ' access_log /var/log/nginx/dokuwiki.access.log;'
            ' error_log /var/log/nginx/dokuwiki.error.log;'
            ''
            ' index index.php doku.php;'
            ''
            'location / {'
            ' try_files $uri $uri/ @dokuwiki;'
            ' }'
            ''
            'location @dokuwiki {'
            ' rewrite ^/_media/(.*) /lib/exe/fetch.php?media=$1 last;'
            ' rewrite ^/_detail/(.*) /lib/exe/detail.php?media=$1 last;'
            ' rewrite ^/_export/([^/]+)/(.*) /doku.php?do=export_$1&id=$2 last;'
            ' rewrite ^/(.*) /doku.php?id=$1 last;'
            ' }'
            ''
            'location ~ /(data|conf|custom|bin|inc)/ {'
            ' deny all;'
            ' }'
            ''
            'location ~* \.(css|js|gif|jpe?g|png)$ {'
            ' expires 1M;'
            ' add_header Pragma public;'
            ' add_header Cache-Control "public, must-revalidate, proxy-revalidate";'
            ' }'
            ''
            'location ~ \.php$ {'
            ' fastcgi_split_path_info ^(.+\.php)(/.+)$;'
            ' fastcgi_pass unix:'"${init_php_[socket]}"';'
            ' fastcgi_index index.php;'
            ' include fastcgi_params;'
            ' fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;'
            ' fastcgi_intercept_errors off;'
            ' fastcgi_buffer_size 16k;'
            ' fastcgi_buffers 4 16k;'
            ' }'
            ''
            'location ~ /\.ht {'
            ' deny all;'
            ' }'
            '}'
        )                                                                       &&
        : || { err "error at init server." ; return 1 ; }

    elif [[ "${user_opt}" == info ]] ; then
        init_server_[port]="$(
            sed -n "s/^${s}*listen${s}\+\(${d}\+\)[\;]/\1/p" "${init_server_[conf]}"
        )"

    else
        :
    fi                                                                          &&

    # run
    ${user_func} "${@}"                                                         &&

    : || return 1

} &&

schulwiki "${@}"
