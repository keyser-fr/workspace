#!/usr/bin/env bash

ACTION=0
COMPONENTS=0
DEBUG=0
DRY_RUN=0

function usage {
    printf "\n"
    printf "Usage: $0 --action <start|stop> --components <all|base|addons> [OPTIONS]\n\n"
    printf "Options:\n"
    printf "\t%-20s %-50s\n" "--action" "Select action <start|stop>"
    printf "\t%-20s %-50s\n" "--components" "Select components <all|base|addons>"
    printf "\t%-20s %-50s\n" "--debug" "Debug mode"
    printf "\t%-20s %-50s\n" "--dry-run" "Dry-run mode"
    printf "\t%-20s %-50s\n" "-h, --help" "Show help"
    printf "\t%-20s %-50s\n" "-v, --version" "Show version"
}

if [[ -z $1 ]]; then
    usage
    exit 1
fi

# read the options
GET_OPTS=`getopt -o hv --long action:,components:,debug,dry-run,help,version -n "$0" -- "$@"`
eval set -- "${GET_OPTS}"

# extract options and their arguments into variables.
while true; do
    case "$1" in
	--action)
	    ACTION=1
	    case "$2" in
		start)
		    COMPOSE_ACTION="up -d"
		    shift 2;;
		stop)
		    COMPOSE_ACTION="down"
		    shift 2;;
		*) echo "[ERROR] Choose action <start|stop>"; exit 1;;
	    esac;;
	--components)
	    COMPONENTS=1
	    case "$2" in
		all)
		    COMPOSE_COMPONENTS="-f docker-compose_base.yaml -f docker-compose_addons.yaml"
		    shift 2;;
		base)
		    COMPOSE_COMPONENTS="-f docker-compose_base.yaml"
		    shift 2;;
		addons)
		    COMPOSE_COMPONENTS="-f docker-compose_addons.yaml"
		    shift 2;;
		*) echo "[ERROR] Choose components <all|base|addons>"; exit 1;;
	    esac;;
	--debug)
	    DEBUG=1;
	    shift;;
	--dry-run)
	    DRY_RUN=1;
	    shift;;
	-h|--help)
	    usage;
	    exit 0;;
	-v|--version)
	    echo "$0 v1.0.0";
	    exit 0;;
	--) shift; break;;
	*) echo "[ERROR] Internal error!"; usage; exit 1;;
    esac
done

if [[ ${ACTION} == 0 || ${COMPONENTS} == 0 ]]; then
    usage
    exit 1
else
    if [[ ${DRY_RUN} == 1 ]]; then
	printf "[DRY-RUN] docker-compose ${COMPOSE_COMPONENTS} ${COMPOSE_ACTION}\n"
    else
	if [[ ${DEBUG} == 1 ]]; then
	    printf "[EXECUTE] docker-compose ${COMPOSE_COMPONENTS} ${COMPOSE_ACTION}\n"
	fi
	printf "[REAL EXECUTE] docker-compose ${COMPOSE_COMPONENTS} ${COMPOSE_ACTION}\n"
    fi
fi

exit 0
