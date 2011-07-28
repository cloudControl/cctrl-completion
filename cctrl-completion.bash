__cctrl_user ()
{
    __cctrl

    local cur prev opts

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "$cur" in
        --*)
            opts="--help --version"
            ;;
        -*)
            opts="-h --help -v --version"
            ;;
        *)
            opts="create activate delete key key.add key.remove logout"
            ;;
    esac

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
__cctrl_app ()
{
    __cctrl

    local app_opts="create details delete user user.add user.remove"
    local deployment_opts="create details deploy undeploy push addon addon.list addon.add addon.upgrade addon.downgrade addon.remove alias alias.add alias.remove worker worker.add worker.remove cron cron.add cron.remove log"
    local cur prev opts

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # transform strings into arrays
    apps=($CCTRL_APPS)
    deployments=($CCTRL_DEPLOYMENTS)

    case "$cur" in
        -*)
            opts="-h -l -v"
            ;;
        *)
            if [[ ${apps[*]} =~ $prev ]]
            then
                opts=${app_opts}
            else if [[ ${deployments[*]} =~ $prev ]]
                then
                    opts=${deployment_opts}
                else
                    opts="${CCTRL_APPS} ${CCTRL_DEPLOYMENTS}"
                fi
            fi
            ;;
    esac

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}

__cctrl ()
{
    _cctrl_cache_warmup
}

# TODO: Remove caching once cctrlapp itself caches its responses.
_cctrl_cache_warmup ()
{
    if [[ ! $CCTRL_APPS ]]; then
        apps=(`cctrlapp -l | cut -d" " -f 5 -s  | grep -e '^[a-zA-Z]'`)
        deployments=()
        for app in ${apps[@]}; do
            for deployment in `cctrlapp $app details | grep "$app/"`; do
                deployments[${#deployments[*]}]="$deployment"
            done
        done

        export CCTRL_APPS=${apps[@]}
        export CCTRL_DEPLOYMENTS=${deployments[@]}
    fi
}

complete -o default -F __cctrl_app cctrlapp
complete -o default -F __cctrl_user cctrluser