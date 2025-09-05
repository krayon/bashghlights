#!/bin/bash

declare -A col colfg
colfg['pink']="\033[1;35m"
colfg['lightgreen']="\033[1;32m"
colfg['lightred']="\033[1;31m"
colfg['lightgrey']="\033[0;37m"
colfg['yellow']="\033[1;33m"
col['reset']="\033[0m"

col['overall']="${colfg['lightgreen']}"
col['operational']="${colfg['lightgreen']}"
col['outage']="${colfg['lightred']}"
col['degraded']="${colfg['yellow']}"
col['unknown']="${colfg['pink']}"

logo="${colfg['pink']}"'\uE709'"${col['reset']}"

declare -a serviceOrder

serviceOrder=(
        "Git Operations "
        "API Requests   "
        "Webhooks       "
        "Issues         "
        "Pull Requests  "
        "Actions        "
        "Packages       "
        "Pages          "
        "Codespaces     "
        "Copilot        "
)
worst_status='operational'

# <serviceA> <serviceB>
laststatus=''
draw2services() {
    local sym=':'

    [ "${1}" == 'outage' ] || [ "${2}" == 'outage' ] && {
        [ "${laststatus}" != 'outage' ] && echo -en "${col['outage']}"
        laststatus='outage'

        [ "${1}" != 'operational' ] && [ "${2}" != 'operational' ] && echo -n '!' && return
        [ "${1}" == "outage"      ] && echo -n "'" || echo -n ","
        return
    }

    [ "${1}" == "degraded" ] || [ "${2}" == "degraded" ] && {
        [ "${laststatus}" != "degraded" ] && echo -en "${col['degraded']}"
        laststatus='degraded'

        [ "${1}" != 'operational' ] && [ "${2}" != 'operational' ] && echo -n '!' && return
        [ "${1}" == 'degraded'    ] && echo -n "'" || echo -n ","
        return
    }

    [ "${1}" == "operational" ] && [ "${2}" == "operational" ] && {
        [ "${laststatus}" != "operational" ] && echo -en "${col['overall']}"
        laststatus='operational'

        echo -n ':'
        return
    }

    # Unknown
    [ "${laststatus}" != "unknown" ] && echo -en "${col['unknown']}"
    laststatus='unknown'

    [ "${1}" != 'operational' ] && [ "${2}" != 'operational' ] && echo -n '?' && return
    [ "${1}" == 'unknown'     ] && echo -n "'" || echo -n ","
}



detailed=0
[ "${1}" == '--detailed' ] && detailed=1 && shift 1
[ "${1}" == '--short'    ] && detailed=0 && shift 1
[ "${1}" == '-s'         ] && detailed=0 && shift 1

[ ! -r "${1}" ] && {
    >&2 echo "ERROR: JSON summary file required"
    exit 1
}



declare -A statuses

#jq -r '.components[] | .name + "|" + .status' <summary.json
while read -r line; do #{
    name="${line%%|*}"; status="${line#*|}"

    # Only known statuses
    [ "${status}" != 'operational' ] && \
    [ "${status}" != 'outage'      ] && \
    [ "${status}" != 'degraded'    ] && \
    status='unknown'

    statuses["${name}"]="${status}"
    [ "${status}" != 'operational' ] && {
        col['overall']="${colfg['lightgrey']}"

        # Urgh! 
        [ "${status}" == 'outage'   ] && worst_status='outage'
        [ "${status}" == 'degraded' ] && [ "${worst_status}" != 'outage'   ] && worst_status='degraded'
        [ "${status}" == 'unknown'  ] && [ "${worst_status}" != 'outage'   ] && [ "${worst_status}" != 'degraded'  ] && worst_status='unknown'
    }
done < <(
    jq -r '.components[] | .name + "|" + .status' <"${1}"
) #}

echo -en "${logo}"


if [ ${detailed} -eq 0 ]; then #{

i=0
serviceout=()
for service in "${serviceOrder[@]}"; do #{
    k="$(sed 's# *$##' <<<"${service}")"
    status="${statuses[${k}]}"
    [ -z "${status}" ] && continue

#    >&2 echo "${service}:${status}"

    serviceout[${i}]="${status}"

    [ ${i} -eq 0 ] && i=1 && continue

    draw2services "${serviceout[0]}" "${serviceout[1]}"
    i=0
done #}
echo -e "${col['reset']}"

exit 0

fi #}

echo -e "${col[${worst_status}]} GitHub Status ${logo}"
echo
for service in "${serviceOrder[@]}"; do #{
    k="$(sed 's# *$##' <<<"${service}")"
    status="${statuses[${k}]}"

    [ -z "${status}" ] && continue

    [ "${status}" == "operational" ] && {
        echo -en "${service}: ${col[${status}]}"
    } || {
        echo -en "${col[${status}]}${service}: "
    }

    #echo -e "${service}: ${col[${status}]}${status}${col['reset']}"
    echo -e "${status}${col['reset']}"
done #}
