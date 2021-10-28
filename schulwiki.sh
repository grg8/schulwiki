#!/bin/bash
#---
# file      : schulwiki.sh
# date      : 28.10.2021
# version   : 0.0.9
# info      : customized dokuwiki wrapper script
#---

##
schulwiki() {

    ### configuration (defaults)
    conf() {

        conf_usage="USAGE${n}${nt}schulwiki COMMAND${nt}schulwiki COMMAND ARG"

        conf_opt_=(
            [help]="${ntt}"'Show this help.'
            [list]="${ntt}"'List all existing wikis.'
            [info]='NAME'"${ntt}"'Show information about a wiki.'
            [reload]='NAME'"${ntt}"'Reload wiki and restart services.'
            [index]='NAME'"${ntt}"'Like '"'"'reload'"'"' but also refresh wiki search index.'
            [pkg]="${ntt}"'Install nginx, php and php stuff for Debian distro.'
            [repo]='NAME'"${ntt}"'Create the repository for a wiki to sync from.'
            [server]='NAME PORT'"${ntt}"'Create http server configuration if not existing.'
            [sync]='NAME'"${ntt}"'Sync from repo to running wiki.'
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
            nginx php
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

        init_repo="${conf_def_[repo]}/${conf_def_[name]}/${user_name}"          &&
        init_repo_=(
            [dokuwiki]="${init_repo}/dokuwiki"
            [plugins]="${init_repo}/plugins"
            [skel]="${init_repo}/skel"
            [tpl]="${init_repo}/tpl"
        )                                                                       &&

        init_dokuwiki="${conf_def_[root]}/${conf_def_[name]}/${user_name}"      &&
        init_dokuwiki_=(
            [dokuwiki]="${init_dokuwiki}"
            [plugins]="${init_dokuwiki}/lib/plugins"
            [skel]="${init_dokuwiki}"
            [tpl]="${init_dokuwiki}/lib/tpl"
        )                                                                       &&

        init_backup="${init_repo}/backup"                                       &&
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
            [conf]="${conf_def_[server]}/conf.d/${conf_def_[name]}_${user_name}.conf"
            [nginx]="${conf_def_[server]}/nginx.conf"
            [owner]="${conf_def_[owner]}"
            [group]="${conf_def_[group]}"
        )                                                                       &&

        : || { err "error at init" ; return 1 ; }

    } &&

    ### options

    opt_help() {
        printf "%s\n\n" "${conf_usage}" "COMMAND"                               &&
        printf "%s\n" "${!conf_opt_[@]}"                                        |
        sort                                                                    |
        while IFS= read -r line ; do
            printf "    %s %s\n\n"  "${line}" "${conf_opt_[${line}]}"
        done
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
        [[ -e "${init_server_[conf]}" ]]                                        ||
            printf "%s\n" "${init_nginx_server__[@]}" > "${init_server_[conf]}" ||
        { err "error at server config." ; return 1 ; }
    }

    opt_pkg() {
        apt update                                                              &&
        apt upgrade                                                             &&
        apt-get install "${init_apt__[@]}"                                      &&
        : || { err "could not install prerequisites." ; return 1 ; }
    }

    opt_list() {
        for i in $( ls -A "${init_repo}" ) ; do
            printf "%s\n" "${i}"
        done                                                                    &&
        : || { err "error at list." ; return 1 ; }
    }

    err() {
        set -- "${@:-unknown error}"
        {
            printf "${0}: aborted: %s\n" "${@}"
            printf "%s\n" "Please try \`schulwiki help' for usage."
        } 1>&2
        return 1
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
        declare -x  user_name=                                                  &&
        declare -x  user_opt=                                                   &&

        : || { err "error at cariable declaration." ; return 1 ; }

    }                                                                           &&

    ### aux regex
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

    # check if usage is valid
    if [[ "${user_opt}" =~ help|list|pkg ]] ; then
        :
    else
        [[ "${1}" =~ ${vo} ]]                                                   &&
        user_name="${1}"                                                        &&
        shift                                                                   &&
        : || { err "invalid or missing NAME: ${1}" ; return 1 ; }

    fi                                                                          &&
    : || { err "mad usage" ; return 1 ; }

    # set user function to run
    user_func="opt_${user_opt}"                                                 &&

    ### init
    init                                                                        &&

    ### conditional init

    if [[ "${user_opt}" =~ server|reload|index|info ]] ; then
        # @todo: write out to phprc at /opt/schulwiki; do the maxsize in php ini
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
            #~ upload_max_filesize = 15M
            #~ post_max_size = 15M
            #~ sed -e "s/^upload_max_filesize = .*/upload_max_filesize = 25M/"  -e "s/^post_max_size = .*/post_max_size = 25M/" /etc/php/7.3/fpm/php.ini
        )                                                                       &&
        : || { err "error at php init." ; return 1 ; }
    fi                                                                          &&

    if [[ "${user_opt}" == server ]] ; then
        port="${1:-${init_server_[port]}}"                                      &&
        { [[ ${#@} -eq 0 ]] || shift ; }                                        &&
        [[ "${port}" =~ ^[[:digit:]]+$ ]]                                       &&
        [[ "${port}" -le 65535  ]]                                              &&
        : || { err "invalid port: ${port}" ; return 1 ; }

        init_nginx_server__=(
            'server {'
            ''
            ' listen '"${port}"';'
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
    fi                                                                          &&

    [[ ${#@} -eq 0 ]]                                                           &&
    : || { err "to many arguments: ${1}" ; return 1 ; }

    # run
    ${user_func}                                                                &&

    : || return 1

} &&

schulwiki "${@}"
