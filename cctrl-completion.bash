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
            case "$prev" in
                key.remove)
                    # Ask the API for the list of keys.
                    opts=`cctrluser key | grep -ve '^Keys' | tr -s " " | cut -f2 -d " "`
                    ;;
                *)
                    opts="create activate delete key key.add key.remove logout"
                    ;;
            esac
            ;;
    esac

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}

__addon_change ()
{
    addon_name=`echo $prev | cut -d '.' -f 1`
    addon_options=()
    for addon in ${addons[@]}; do
        if [[ ${addon:0:${#addon_name}} == $addon_name ]]
        then
            addon_options[${#addon_options[*]}]="$addon"
        fi
    done
    opts=${addon_options[@]}
}

__current_addons ()
{
    addonsoutput=(`cctrlapp ${COMP_WORDS[-3]} addon | grep -v '^ ' | cut -d ":" -f 2 | tr -d ' ' | grep -v '^$'`)
    current_addons=()
    for addon in ${addonsoutput[@]}; do
        current_addons[${#current_addons[*]}]="$addon"
    done
    opts=${current_addons[@]}
}

__current_aliases ()
{
    aliasesoutput=(`cctrlapp ${COMP_WORDS[-3]} alias | grep '^ ' | grep -v ' name ' | cut -d ' ' -f 2`)
    current_aliases=()
    for alias in ${aliasesoutput[@]}; do
        current_aliases[${#current_aliases[*]}]="$alias"
    done
    opts=${current_aliases[@]}
}

__current_crons ()
{
    cronsoutput=(`cctrlapp ${COMP_WORDS[-3]} cron | grep '^  ' | cut -d ' ' -f 5`)
    current_crons=()
    for cron in ${cronsoutput[@]}; do
        current_crons[${#current_crons[*]}]="$cron"
    done
    opts=${current_crons[@]}
}


__cctrl_app ()
{
    __cctrl

    local app_opts="create details delete user user.add user.remove addon.list"
    local deployment_opts="details deploy undeploy push addon addon.list addon.add addon.upgrade addon.downgrade addon.remove alias alias.add alias.remove worker worker.add worker.remove cron cron.add cron.remove log open"
    local app_types="java nodejs php python ruby"
    local log_types="access error worker deploy"

    local cur

    opts=""
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # transform strings into arrays
    apps=($CCTRL_APPS)
    deployments=($CCTRL_DEPLOYMENTS)
    addons=($CCTRL_ADDONS)

    case "$cur" in
        -*)
            opts="-h -l -v"
            ;;
        *)
            if [[ ${apps[*]} =~ $prev ]]
            then
                opts=${app_opts}
            else
                if [[ ${deployments[*]} =~ $prev ]]
                then
                    opts=${deployment_opts}
                else
                    case "$prev" in
                        addon)
                            opts=""
                            ;;
                        addon.add)
                            opts=${addons[@]}
                            ;;
                        addon.downgrade)
                            __current_addons
                            ;;
                        addon.list)
                            opts=""
                            ;;
                        addon.remove)
                            __current_addons
                            ;;
                        addon.upgrade)
                            __current_addons
                            ;;
                        alias)
                            opts=""
                            ;;
                        alias.add)
                            opts=""
                            ;;
                        alias.remove)
                            __current_aliases
                            ;;
                        create)
                            opts=$app_types
                            ;;
                        cron)
                            opts=""
                            ;;
                        cron.add)
                            opts=""
                            ;;
                        cron.remove)
                            __current_crons
                            ;;
                        deploy)
                            opts=""
                            ;;
                        details)
                            opts=""
                            ;;
                        log)
                            opts=${log_types}
                            ;;
                        push)
                            opts=""
                            ;;
                        undeploy)
                            opts=""
                            ;;
                        worker)
                            opts=""
                            ;;
                        worker.add)
                            opts=""
                            ;;
                        worker.remove)
                            # First argument is actually a deployment?
                            if [[ ${deployments[*]} =~ ${COMP_WORDS[1]} ]]
                            then
                                # Ask the API for the list of workers.
                                opts=`cctrlapp ${COMP_WORDS[1]} worker | grep -ve '^Workers' | grep -ve '^ nr\.' | tr -s " " | cut -f3 -d " "`
                            fi
                            ;;
                        *)
                            # addon.upgrade/downgrade <addon> <addon>
                            if [[ ${COMP_WORDS[COMP_CWORD-2]} == "addon.upgrade" ]]
                            then
                                __addon_change
                            elif [[ ${COMP_WORDS[COMP_CWORD-2]} == "addon.downgrade" ]]
                            then
                                __addon_change
                            else
                                # only the second argument is the deployment
                                if [[ $COMP_CWORD == 1 ]]
                                then
                                    opts="${CCTRL_APPS} ${CCTRL_DEPLOYMENTS}"
                                fi
                            fi
                            ;;
                    esac
                fi
        fi
        ;;
    esac

    if [[ $(echo ${opts} | tr -d ' ') == "" ]]; then
        if [[ $apps == "" ]]; then
            COMPREPLY=( $(compgen -W "-h -l -v") )
        else
            COMPREPLY=""
        fi
    else
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    fi
    
}

__cctrl ()
{
    _cctrl_cache_warmup
}

_cctrl_cache_warmup_apps ()
{
    apps=(`cctrlapp -l | cut -d" " -f 5 -s  | grep -e '^[a-zA-Z]'`)
    export CCTRL_APPS=${apps[@]}
}

_cctrl_cache_warmup_deployments ()
{
    deployments=()
    for app in ${CCTRL_APPS[@]}; do
        for deployment in `cctrlapp $app details | grep "$app/"`; do
            deployments[${#deployments[*]}]="$deployment"
        done
    done
    export CCTRL_DEPLOYMENTS=${deployments[@]}
}

_cctrl_cache_warmup_addons ()
{
    addonsoutput=(`cctrlapp app addon.list | grep '\.'`)
    addons=()
    for addon in ${addonsoutput[@]}; do
        addons[${#addons[*]}]="$addon"
    done
    export CCTRL_ADDONS=${addons[@]}
}

# TODO: Remove caching once cctrlapp itself caches its responses.
_cctrl_cache_warmup()
{
    if [[ ! $CCTRL_APPS ]]; then
        if ! cctrluser checktoken > /dev/null; then
            return
        fi
        _cctrl_cache_warmup_apps
        _cctrl_cache_warmup_deployments
        _cctrl_cache_warmup_addons
    fi
}

complete -o default -F __cctrl_app cctrlapp
complete -o default -F __cctrl_user cctrluser
