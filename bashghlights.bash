#!/bin/bash
# vim:set ts=4 sw=4 tw=80 et ai si cindent cino=L0,b1,(1s,U1,m1,j1,J1,)50,*90 cinkeys=0{,0},0),0],\:,!^F,o,O,e,0=break:
#
#/**********************************************************************
#    Bash GitHub Lights
#    Copyright (C)2025 Todd Harbour (krayon)
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License
#    version 2 ONLY, as published by the Free Software Foundation.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program, in the file COPYING or COPYING.txt; if
#    not, see http://www.gnu.org/licenses/ , or write to:
#      The Free Software Foundation, Inc.,
#      51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# **********************************************************************/

# bashghlights
# ------------
# bashghlights outputs the status of GitHub.com in various formats
#
# Required:
#     sed
# Recommended:
#     -

# Config paths
_APP_NAME="bashghlights"
_CONF_FILENAME="${_APP_NAME}.conf"



############### STOP ###############
#
# Do NOT edit the CONFIGURATION below. Instead generate the default
# configuration file in your XDG_CONFIG directory thusly:
#
#     ./bashghlights.bash -C >"$XDG_CONFIG_HOME/bashghlights.conf"
#
# or perhaps:
#     ./bashghlights.bash -C >~/.config/bashghlights.conf
#
# or even in your home directory (deprecated):
#     ./bashghlights.bash -C >~/.bashghlights.conf
#
# Consult --help for more complete information.
#
####################################

# [ CONFIG_START

# Bash GitHub Lights (bashghlights) - Default Configuration
# =========================================================

# DEBUG
#   This defines debug mode which will output verbose info to stderr or, if
#   configured, the debug file ( ERROR_LOG ).
DEBUG=0

# ERROR_LOG
#   The file to output errors and debug statements (when DEBUG != 0) instead of
#   stderr.
#ERROR_LOG="${HOME}/bashghlights.log"

# PATH_SED
#   The path to the sed binary. If set to "*", $PATH is used (ie.
#   "sed" called without a path).
PATH_SED="*"

# PATH_WGET
#   The path to the wget binary. If set to "*", $PATH is used (ie.
#   "wget" called without a path).
PATH_WGET="*"

# TODO: Default option, colours etc

detailed=0

# UPDATE_FREQ
#   How often the status should be updated. When bashghlights is executed, it
#   will update its status database when it is older than this number of
#   seconds. 0 means update each time.
UPDATE_FREQ=300

# PATH_FILE_STATUS
#   The path to the status file.
PATH_FILE_STATUS="${XDG_CONFIG_HOME}/${_APP_NAME}/status.json"

# ] CONFIG_END



####################################{
###
# Config loading
###

# A list of configs - user provided prioritised over system
# (built backwards to save fiddling with CONFIG_DIRS order)
_CONFS=""

# XDG Base (v0.8) - User level
# ( https://specifications.freedesktop.org/basedir-spec/0.8/ )
# ( xdg_base_spec.0.8.txt )
_XDG_CONF_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}"
# As per spec, non-absolute paths are invalid and must be ignored
[ "${_XDG_CONF_DIR:0:1}" == "/" ] && {
        for conf in\
            "${_XDG_CONF_DIR}/${_APP_NAME}/${_CONF_FILENAME}"\
            "${_XDG_CONF_DIR}/${_CONF_FILENAME}"\
        ; do #{
            [ -r "${conf}" ] && _CONFS="${conf}:${_CONFS}"
        done #}
}

# OLD standard for HOME
[ -r "${HOME}/.${_CONF_FILENAME}" ] && _CONFS="${HOME}/.${_CONF_FILENAME}:${_CONFS}"

# XDG Base (v0.8) - System level
# ( https://specifications.freedesktop.org/basedir-spec/0.8/ )
# ( xdg_base_spec.0.8.txt )
_XDG_CONF_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
# NOTE: Appending colon as read's '-d' sets the TERMINATOR (not delimiter)
[ "${_XDG_CONF_DIRS: -1:1}" != ":" ] && _XDG_CONF_DIRS="${_XDG_CONF_DIRS}:"
while read -r -d: _XDG_CONF_DIR; do #{
    # As per spec, non-absolute paths are invalid and must be ignored
    [ "${_XDG_CONF_DIR:0:1}" == "/" ] && {
        for conf in\
            "${_XDG_CONF_DIR}/${_APP_NAME}/${_CONF_FILENAME}"\
            "${_XDG_CONF_DIR}/${_CONF_FILENAME}"\
        ; do #{
            [ -r "${conf}" ] && _CONFS="${conf}:${_CONFS}"
        done #}
    }
done <<<"${_XDG_CONF_DIRS}" #}

# OLD standard for SYSTEM
[ -r "/etc/${_CONF_FILENAME}" ] && _CONFS="/etc/${_CONF_FILENAME}:${_CONFS}"

# _CONFS now contains a list of config files, in reverse importance order. We
# can therefore source each in turn, allowing the more important to override the
# earlier ones.

# NOTE: Appending colon as read's '-d' sets the TERMINATOR (not delimiter)
[ "${_CONF: -1:1}" != ":" ] && _CONF="${_CONF}:"
while read -r -d: conf; do #{
    . "${conf}"
done <<<"${_CONFS}" #}
####################################}



# Version
APP_NAME="Bash GitHub Lights (bashghlights)"
APP_VER="0.01"
APP_COPY="(C)2025 Krayon (Todd Harbour)"
APP_URL="https://github.com/krayon/bashghlights/"

# Program name
_binname="${_APP_NAME}"
_binname="${0##*/}"
_binnam_="${_binname//?/ }"

# exit condition constants
ERR_NONE=0
ERR_DEGRADED=1
ERR_OUTAGE=2
ERR_UNKNOWN=10
# START /usr/include/sysexits.h {
ERR_USAGE=64       # command line usage error
ERR_DATAERR=65     # data format error
ERR_NOINPUT=66     # cannot open input
ERR_NOUSER=67      # addressee unknown
ERR_NOHOST=68      # host name unknown
ERR_UNAVAILABLE=69 # service unavailable
ERR_SOFTWARE=70    # internal software error
ERR_OSERR=71       # system error (e.g., can't fork)
ERR_OSFILE=72      # critical OS file missing
ERR_CANTCREAT=73   # can't create (user) output file
ERR_IOERR=74       # input/output error
ERR_TEMPFAIL=75    # temp failure; user is invited to retry
ERR_PROTOCOL=76    # remote error in protocol
ERR_NOPERM=77      # permission denied
ERR_CONFIG=78      # configuration error
# END   /usr/include/sysexits.h }
ERR_MISSINGDEP=90

# Defaults not in config

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

# Service order from https://github.com/oskarpie/GitHubLights.git
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



# Params:
#   $1 =  (s) command to look for
#   $2 = [(s) complete path to binary, DEFAULT: $1]
#   $3 = [(i) print error? (1 = yes, 0 = no), DEFAULT: yes]
#   $4 = [(i) is this a required package? (1 = yes, 0 = no), DEFAULT: yes]
#   $5 = [(s) suspected package name]
# Outputs:
#   Path to command, if found
# Returns:
#   $ERR_NONE
#   -or-
#   $ERR_MISSINGDEP
check_for_cmd() {
    # Check for ${1} command
    local ret=${ERR_NONE}
    local path='' cmd='' bin='' msg='' req='' pkg=''
    [ ${#} -ge 1 ] && cmd="${1}" && shift 1
    [ ${#} -ge 1 ] && bin="${1}" && shift 1
    [ ${#} -ge 1 ] && msg="${1}" && shift 1
    [ ${#} -ge 1 ] && req="${1}" && shift 1
    [ ${#} -ge 1 ] && pkg="${1}" && shift 1

    [ -z "${bin}" ] && bin="${cmd}"
    [ -z "${msg}" ] && msg="1"
    [ -z "${req}" ] && req="1"
    [ -z "${pkg}" ] && pkg="${cmd}"

    path="$(type -P "${bin}" 2>&1)" || {
        # Not found
        ret=${ERR_MISSINGDEP}

        [ "${msg}" -eq 1 ] &>/dev/null && {
            [ "${req}" -eq 0 ] && {
                unset req req_head
            } || {
                req='  This is required.'
                req_head='ERROR'
            }

cat <<EOF >&2
${req_head:-WARNING}: Cannot find ${cmd}${bin:+ (as }${bin}${bin:+)}.${req:-}
Ensure it is in your PATH, set (or unset) an explicit path in the configuration,
confirm you have ${pkg} installed or search for ${cmd} in your distribution's
packages.
EOF

            return ${ret}
        }
    }

    [ ! -z "${path}" ] && echo "${path}"

    return ${ret}
} # check_for_cmd()

# Params:
#   NONE
show_version() {
    echo -e "\n\
${APP_NAME} v${APP_VER}\n\
${APP_COPY}\n\
${APP_URL}${APP_URL:+\n}\
"
} # show_version()

# Params:
#   NONE
show_usage() {
    show_version

cat <<EOF

${APP_NAME} outputs the status of GitHub.com in various formats

Usage: ${_binname} [-v|--verbose] -h|--help
       ${_binname} [-v|--verbose] -V|--version
       ${_binname} [-v|--verbose] [-c|--configfile <conffile>] -C|--configuration

       ${_binname} [-v|--verbose] [-c|--configfile <conffile>]

-h|--help           - Displays this help
-V|--version        - Displays the program version
-c|--configfile     - Use config file to OVERLOAD default configuration. Note
                      that all the existing configuration files are still
                      processed PRIOR to the specified configuration file.
-C|--configuration  - Outputs the default configuration that can be placed in a
                      config file in XDG_CONFIG or one of the XDG_CONFIG_DIRS
                      (in order of decreasing precedence):
                          * COMMAND LINE PROVIDED CONFIG USING -c/--configfile *
                          ${XDG_CONFIG_HOME:-${HOME}/.config}/${_APP_NAME}/${_CONF_FILENAME}
                          ${XDG_CONFIG_HOME:-${HOME}/.config}/${_CONF_FILENAME}
                          ${HOME}/.${_CONF_FILENAME}
EOF
    while read -r -d: _XDG_CONF_DIR; do #{
        # As per spec, non-absolute paths are invalid and must be ignored
        [ "${_XDG_CONF_DIR:0:1}" != "/" ] && continue
cat <<EOF
                          ${_XDG_CONF_DIR}/${_APP_NAME}/${_CONF_FILENAME}
                          ${_XDG_CONF_DIR}/${_CONF_FILENAME}
EOF
    done <<<"${_XDG_CONF_DIRS:-/etc/xdg}:" #}
cat <<EOF
                          /etc/${_CONF_FILENAME}
                      for editing.
-v|--verbose        - Displays extra debugging information.  This is the same
                      as setting DEBUG=1 in your config.
-s|--short          - Display only a short (7 characters) to represent the
                      status. This is designed to match GitHub Lights for MacOS.
                      This is great for including in your PS1 prompt.
-d|--detailed       - Displays a detailed list of GitHub services and their
                      current status.

When executed correctly, ${_binname} will return ERR_NONE (${ERR_NONE}) if all
services are operational, ERR_DEGRADED (${ERR_DEGRADED}) if one or more are
degraded, and ERR_OUTAGE (${ERR_OUTAGE}) if one or more are experiencing an
outage. ERR_UNKNOWN (${ERR_UNKNOWN}) is returned if the status cannot be
determined. In the event an error occurs, a larger error number will be returned
( > ${ERR_UNKNOWN} ).

Example: ${_binname} -s
EOF

} # show_usage()

# Output configuration file
output_config() {
    local sed="${PATH_SED}"

    # Special case since we've not resolved our paths yet
    [ "${PATH_SED}" == '*' ] && sed='sed'
    "${sed}" -n '/^# \[ CONFIG_START/,/^# \] CONFIG_END/p' <"${0}"
} # output_config()

# Debug echo
decho() {
    # global $DEBUG
    local line

    # Not debugging, get out of here then
    [ -z "${DEBUG}" ] || [ "${DEBUG}" -le 0 ] && return 0

    # If message is "-" or isn't specified, use stdin ("" is valid input)
    msg="${@}"
    [ ${#} -lt 1 ] || [ "${msg}" == "-" ] && msg="$(</dev/stdin)"

    while IFS="" read -r line; do #{
        >&2 echo "[$(date +'%Y-%m-%d %H:%M')] DEBUG: ${line}"
    done< <(echo "${msg}") #}
} # decho()



#----------------------------------------------------------
# START #

refreshstatus() {
    local dir

    [ $(( $(date +%s) - $([ -r "${PATH_FILE_STATUS}" ] && stat --format=%Y "${PATH_FILE_STATUS}" || echo 0) )) -gt "${UPDATE_FREQ}" ] || return

    dir="${PATH_FILE_STATUS%/*}/"
    [ ! -d "${dir}" ] && {
        mkdir "${dir}" || {
            >&2 echo "ERROR: Cannot create configuration directory: ${dir}"
            exit ${ERR_NOPERM}
        }
    }

    wget -qO "${PATH_FILE_STATUS}.tmp" "https://www.githubstatus.com/api/v2/summary.json" || {
        >&2 echo "ERROR: Failed to update GitHub service summary"
        exit ${ERR_UNAVAILABLE}
    }

    mv "${PATH_FILE_STATUS}.tmp" "${PATH_FILE_STATUS}"
}

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



# Clear DEBUG if it's 0
[ -n "${DEBUG}" ] && [ "${DEBUG}" == "0" ] && DEBUG=

ret=${ERR_NONE}

# If debug file, redirect stderr out to it
[ -n "${ERROR_LOG}" ] && exec 2>>"${ERROR_LOG}"

#----------------------------------------------------------



# Process command line parameters
opts=$(\
    getopt\
        --options v,h,V,c:,C,s,d\
        --long verbose,help,version,configfile:,configuration,short,detailed\
        --name "${APP_NAME}"\
        --\
        "$@"\
) || {
    >&2 echo "ERROR: Syntax error"
    >&2 show_usage
    exit ${ERR_USAGE}
}

eval set -- "${opts}"
unset opts

while :; do #{
    case "${1}" in #{
        # Verbose mode first to enable DEBUG ASAP
        # Verbose mode # [-v|--verbose]
        -v|--verbose)
            decho "Verbose mode specified"
            DEBUG=1
        ;;

        # Config file ASAP to ensure the values are observed
        # Load configuration file # -c|--configfile
        -c|--configfile)
            conf="${2}"

            decho "Config file: ${conf}"

            [ -r  "${conf}" ] && {
                . "${conf}"
            } || {
                # ERROR: can't read config file
                >&2 echo "ERROR: Cannot read configuration file: ${conf}"
                exit ${ERR_IOERR}
            }
        ;;

        # Help # -h|--help
        -h|--help)
            decho "Help"

            show_usage
            exit ${ERR_NONE}
        ;;

        # Version # -V|--version
        -V|--version)
            decho "Version"

            show_version
            exit ${ERR_NONE}
        ;;

        # Configuration output # -C|--configuration
        -C|--configuration)
            decho "Configuration"

            output_config
            exit ${ERR_NONE}
        ;;

        # Short output # -s|--short
        -s|--short)
            decho "Short"

            detailed=0
        ;;

        # Detailed output # -d|--detailed
        -d|--detailed)
            decho "Detailed"

            detailed=1
        ;;

        --)
            shift
            break
        ;;

        -)
            # Read stdin
            #set -- "/dev/stdin"
            # FALL THROUGH TO FILE HANDLER BELOW
        ;;

        *)
            >&2 echo "ERROR: Unrecognised parameter ${1}..."
            exit ${ERR_USAGE}
        ;;
    esac #}

    shift

done #}

# TODO: Check for non-optional parameters

# TODO: Are you NOT supporting non-specific parameters?
## Unrecognised parameters
#[ ${#} -gt 0 ] && {
#    >&2 echo "ERROR: Too many parameters: ${@}..."
#    exit ${ERR_USAGE}
#}

# Check for dependencies

# sed (REQUIRED)
decho "Path for sed set to: '${PATH_SED}'..."
[ "${PATH_SED}" == "*" ] && PATH_SED="sed"
PATH_SED="$(check_for_cmd "sed" "${PATH_SED}" 1 1)" || exit $?
decho "sed path: ${PATH_SED}"

# wget (REQUIRED)
decho "Path for wget set to: '${PATH_WGET}'..."
[ "${PATH_WGET}" == "*" ] && PATH_WGET="wget"
PATH_WGET="$(check_for_cmd "wget" "${PATH_WGET}" 1 1)" || exit $?
decho "wget path: ${PATH_WGET}"



decho "START"



infile="${1}"; shift 1
[ ! -r "${infile}" ] && {
    refreshstatus

    [ -r "${PATH_FILE_STATUS}" ] && infile="${PATH_FILE_STATUS}" || {
        >&2 echo "ERROR: JSON summary file required"
        exit ${ERR_NOINPUT}
    }
}

declare -A statuses
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
    jq -r '.components[] | .name + "|" + .status' <"${infile}" || {
        >&2 echo "ERROR: Failed to parse JSON summary: ${infile}"
        exit ${ERR_DATAERR}
    }
) #}

if [ ${detailed} -eq 0 ]; then #{

i=0
serviceout=()
echo -en "${logo}"
for service in "${serviceOrder[@]}"; do #{
    k="$(sed 's# *$##' <<<"${service}")"
    status="${statuses[${k}]}"
    [ -z "${status}" ] && continue

    serviceout[${i}]="${status}"

    [ ${i} -eq 0 ] && i=1 && continue

    draw2services "${serviceout[0]}" "${serviceout[1]}"
    i=0
done #}
echo -e "${logo}${col['reset']}"

else #} {

echo -e "${logo} ${col[${worst_status}]}GitHub Status${col['reset']} ${logo}"
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

    echo -e "${status}${col['reset']}"
done #}

fi #}

[ "${worst_status}" == 'degraded'    ] && exit ${ERR_DEGRADED}
[ "${worst_status}" == 'outage'      ] && exit ${ERR_OUTAGE}
[ "${worst_status}" == 'unknown'     ] && exit ${ERR_UNKNOWN}
[ "${worst_status}" == 'operational' ] && exit ${ERR_NONE}
