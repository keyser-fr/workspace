#! /bin/bash
#
# $Id: edsh.sh 183 2012-03-29 13:35:30Z <login> $
# $HeadURL: <url> $
#
# ==================
## Informations ----
# ==================
#  Auteur: <author>
#     Date: 11/07/2011
# Versions:
#           2.0 - <login> - Creation
#           3.0 - <login> - Ajout modif option (-f -> -y),
#			 - modif (-g -> -f), et ajout (-f)
#			 - Ajout option -o
#
# vim: ts=4


# ==================
## Variables -------
# ==================
VERSION="3.1"
DSH='/usr/bin/dsh'
HOSTS_LIST=''
LDAP='true'
LDAP_HOST='ldap.infra.s1.p.fti.net'
CFE_HOST='svn01.prod.cfengine.s1.p.fti.net'
PATH_OPT_GROUP="${HOME}/.dsh/group"
PATH_GROUPPFS="${_HBX_GROUPPFS_PATH:=${HOME}/.pfs/}"
PATH_RAMPUP="${_HBX_RAMPUP_PATH:=${HOME}/.rampup/}"

# Arguments:
OPT_HOSTS=''
OPT_SCRIPT=''
OPT_COMMANDE=''
OPT_FORCE=''
OPT_LOGIN=${EDSH_LOGIN:=${USER}}
OPT_GROUP=''
OPT_GROUPPFS=''
OPT_FILE=''
OPT_DSH=''
OPT_HOSTNAME=''
HOSTS_LIST_TO_VERIFY=''
OPT_EXCLUDE=''
OPT_INCLUDE=''





# ==================
## Fonctions -------
# ==================

function USAGE {
	echo ''
	echo 'Usage:'
	echo "    $( basename $0 ) -m <hostname> -c <remote commande>"
	echo '    -c : Commande.'
	echo '    -m : Nom de machine avec wildcard LDAP (Multiple -m autorise).'
	echo '    -M : Nom de machine avec regex perl    (Multiple -M autorise).'
	echo '    -f : Fichier (liste de machine) (Multiple -f autorise).'
	echo '    -G : Groupes PFS (Multiple -G autorise).'
	echo '    -g : Groupes dsh (~/.dsh/group/<file>) (Multiple -g autorise).'
    echo '    -R : Includes Rampup equal to level (Multiple -R autorise).'
	echo '    -s : Script local a executer sur les machines distante (Option -c incompatible).'
	echo '    -y : By-pass la validation des machines.'
	echo '    -l : Changer le login OU utiliser: export EDSH_LOGIN=toto.'
	echo '    -e : Regex pour exclure des machines de la list.'
	echo '    -i : Regex pour exclusion inverse de machine a la list.'
	echo '    -o : Passer des options a dsh.'
	echo '    -H : Affiche le nom du server en debut de ligne.'
	echo '    -h : Affiche l aide.'
	echo "  Attention, l'ordre des options est important pour inclure/exclure."
	echo ''
	echo 'Documentation (RTFM):'
	echo '    https://<url>
	echo ''
	echo 'Exemples:'
	echo '  Toutes les machines nommees par la regex'
	echo "    $( basename $0 ) -m data0*.voilamail. -c 'hostname'"
	echo '  Toutes du niveau de rampup 40'
	echo "    $( basename $0 ) -R 40 -c 'hostname'"
	echo '  Toutes du niveau de rampup 40 sauf regex'
	echo "    $( basename $0 ) -R 40 -e dev -c 'hostname'"
	echo '  Toutes du niveau de rampup 40 uniquement regex'
	echo "    $( basename $0 ) -R 40 -i dev -c 'hostname'"
	echo ''
}



function regex2hostList {
	found_hosts=$(eval "ssh ${CFE_HOST} -C /usr/local/bin/CFE_update -m \"$1\" 2>/dev/null | sort --key 3 |  tr '\n' ' '" )
	(echo "$found_hosts" | grep "Usage:" &>/dev/null) && found_hosts=''
	[ -n "$found_hosts" ] && HOSTS_LIST_TO_VERIFY="$found_hosts $HOSTS_LIST_TO_VERIFY"
	unset found_hosts
}



function wildcard2hostList {
	found_hosts=$(eval "ldapsearch -h ${LDAP_HOST} -b 'ou=hosts,dc=fti,dc=net' -LLL -s sub -z 100 -x "cn=$1" 'cn' 2>/dev/null | awk '/^cn/ { print \$2 }' 2>/dev/null | sort --key 3 |  tr '\n' ' '")
	[ -n "$found_hosts" ] && HOSTS_LIST_TO_VERIFY="$found_hosts $HOSTS_LIST_TO_VERIFY"
	unset found_hosts
}



function file2hostList {
	direname=$1
	filename=$2
	if [ -e "${direname}${filename}" ]; then
		found_hosts=$(cat ${direname}${filename} |  tr '\n' ' ' )
		[ -n "$found_hosts" ] && HOSTS_LIST_TO_VERIFY="$found_hosts $HOSTS_LIST_TO_VERIFY"
		unset found_hosts
	else
		echo "* Fichier introuvable (${direname}${filename}) *"
		exit 1
	fi
}



function exclude {
	if [ -n "$1" ]; then
		HOSTS_LIST_TO_VERIFY=$(echo "$HOSTS_LIST_TO_VERIFY" | tr ' ' '\n' | grep -v "$1" )
	fi
}

function include {
	if [ -n "$1" ]; then
		HOSTS_LIST_TO_VERIFY=$(echo "$HOSTS_LIST_TO_VERIFY" | tr ' ' '\n' | grep "$1" )
	fi
}






# ==================
## Main ------------
# ==================

if [ $# -lt 1 ]; then
	USAGE
	exit 1
fi


## Arguments:
# ===========
while getopts "i:e:o:g:G:R:s:m:M:c:f:l:hyH" Option; do
	case $Option in
		s ) OPT_SCRIPT="$OPTARG";;
		H ) OPT_HOSTNAME="-M";;
		e ) exclude "$OPTARG";;
		i ) include "$OPTARG";;
		c ) OPT_COMMANDE="$OPTARG";;
		l ) OPT_LOGIN="$OPTARG";;
		m ) wildcard2hostList "${OPTARG}";;
		M ) regex2hostList "${OPTARG}";;
		g ) file2hostList "${HOME}/.dsh/group/" "$OPTARG";;
		G ) file2hostList "${PATH_GROUPPFS}/" "${OPTARG}";;
        R ) file2hostList "${PATH_RAMPUP}" "${OPTARG}";;
		f ) file2hostList "" "${OPTARG}";;
		y ) OPT_FORCE="true";;
		o ) OPT_DSH="$OPTARG";;
		h | help ) USAGE; exit 0;;
		* ) echo "** Option inconnu. **"; USAGE; exit 1;;   # Default.
	esac
done




## Format the Host list:
# ======================
if [ -n "$HOSTS_LIST_TO_VERIFY" ]; then

	if [ "$OPT_FORCE" != "true" ]; then
		echo 'Liste de machine:'
	fi

	# Build line
	for host in $HOSTS_LIST_TO_VERIFY; do
		if [ -n "$OPT_LOGIN" ]; then
			host="$OPT_LOGIN@$host"
		fi
		if [ "$OPT_FORCE" != "true" ]; then
			echo " - $host"
		fi
		HOSTS_LIST="$host,$HOSTS_LIST"
	done

	HOSTS_LIST="$( echo "${HOSTS_LIST}" | sed -e 's/,$//' )"

else
	echo "** Aucune machine trouvee! **"
	exit 1
fi
unset HOSTS_LIST_TO_VERIFY




## Ready ?
# ========

if [ -z "$OPT_SCRIPT" ] && [ -z "$OPT_COMMANDE" ]; then
	OPT_FORCE="true"
fi

if [ "$OPT_FORCE" != "true" ]; then
	echo ''
	echo -n "Pour continuer taper OUI: "
	read ANSWER
	echo "-----------------"
else
	ANSWER="OUI"
fi

if [ -z "$OPT_SCRIPT" ] && [ -z "$OPT_COMMANDE" ]; then
	echo "No action given... exit!"
	exit 1
fi



## Let's go..
# ===========
if [ "$ANSWER" == "OUI" ];then
    if [ -n "$OPT_DSH" ]; then
        OPT_DSH=" -o \"$OPT_DSH\""
    fi
	if [ -n "$OPT_SCRIPT" ] && [ -r "$OPT_SCRIPT" ]; then
		shebang=$( grep "^#\!"  --max-count=1  "${OPT_SCRIPT}" | sed 's/^#\!//')
		CMD="cat '${OPT_SCRIPT}' | ${DSH} ${OPT_HOSTNAME} ${OPT_DSH} --duplicate-input --concurrent-shell -m $HOSTS_LIST '${shebang}'"
	elif [ -z "$OPT_SCRIPT" ] && [ -n "$OPT_COMMANDE" ]; then
		CMD="$DSH ${OPT_HOSTNAME} ${OPT_DSH} -m $HOSTS_LIST -- '$OPT_COMMANDE'"
	else
		echo "** Commande ou script incorrects! **"
		USAGE
		exit 1
	fi
	eval "${CMD}"
else
	echo "Annuler."
fi
