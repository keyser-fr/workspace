#! /bin/bash
#
# $Id: $
# $HeadURL: $
#
# ==================
## Informations ----
# ==================
#  Auteur: <author>
#     Date: 24/01/2012
# Versions:
#           1.0 - <login> - Creation
#
# vim: ts=4


# ==================
## Variables -------
# ==================
VERSION="1.0"
CSSH='/usr/bin/cssh'
HOSTS_LIST=''
LDAP_HOST='ldap.infra.s1.p.fti.net'
CFE_HOST='svn01.prod.cfengine.s1.p.fti.net'
PATH_GROUPPFS="${_HBX_GROUPPFS_PATH:=${HOME}/svn/groupPFS/}"

# Arguments:
OPT_COMMANDE=''
OPT_CSSH=''
OPT_FORCE=''
OPT_LOGIN=${ECSSH_LOGIN:=${USER}}
OPT_INCLUDE=''
OPT_EXCLUDE=''




# ==================
## Fonctions -------
# ==================

function USAGE {
	echo 'Usage:'
	echo "    $( basename $0 ) -m <reghex_host> -c <remote commande>"
	echo '    -c : Commande.'

	echo '    -m : Machine avec wildcard LDAP (Multiple -m autorise).'
	echo '    -M : Machine avec regex perl    (Multiple -M autorise).'
	echo '    -f : Fichier (liste de machine) (Multiple -f autorise).'
	echo '    -G : Groupes PFS (cfengine)     (Multiple -G autorise).'
	echo '    -g : Groupes dsh (~/.dsh/group/<file>) (Multiple -g autorise).'

	echo '    -y : By-pass la validation des machines.'
	echo '    -l : Changer le login OU utiliser: export ECSSH_LOGIN=toto.'

	echo '    -e : Regex pour exclure des machines de la list.'
	echo '    -i : Regex pour exclusion inverse de machine a la list.'

	echo '    -o : Passer des options a cssh.'
	echo '    -h : Affiche l aide.'
	echo ''
	echo 'Documentation (RTFM):'
	echo '    https://<url>
	echo ''
	echo 'Exemples:'
	echo "    $( basename $0 ) -m data0*.voilamail. -c 'tail -n 1 /var/log/messages'"
	echo "    $( basename $0 ) -m *vabf.vrec.ecare* -r -m \"[www,admin]01.integ.vrec.ecare\" -c hostname -l root"
	echo ''
}




function regex2hostList {
	found_hosts=$(eval "ssh ${CFE_HOST} -C /usr/local/bin/CFE_update -m \"$1\" 2>/dev/null | sort --key 3 | sed '/^$/d' | tr '\n' ' '" )
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








# ==================
## Main ------------
# ==================


if [ $# -lt 1 ]; then
	USAGE
	exit 1
fi


## Arguments:
# ===========
while getopts "i:e:o:g:G:m:M:c:f:l:hy" Option; do
	case $Option in
		c ) OPT_COMMANDE="--action \'$OPTARG\'";;
		e ) OPT_EXCLUDE="$OPTARG";;
		i ) OPT_INCLUDE="$OPTARG";;
		l ) OPT_LOGIN="$OPTARG";;
		m ) wildcard2hostList ${OPTARG};;
		M ) regex2hostList ${OPTARG};;
		g ) file2hostList "${HOME}/.dsh/group/" "$OPTARG";;
		G ) file2hostList "${PATH_GROUPPFS}/" "${OPTARG}";;
		f ) file2hostList "" "${OPTARG}";;
		y ) OPT_FORCE="true";;
		o ) OPT_CSSH="$OPTARG";;
		h | help ) USAGE; exit 0;;
		* ) echo "** Unimplemented option chosen. **"; USAGE; exit 1;;   # Default.
	esac
done


## Format the Host list:
# ======================
if [ -n "$HOSTS_LIST_TO_VERIFY" ]; then

	if [ "$OPT_FORCE" != "true" ]; then
		echo 'Liste de machine:'
	fi

	# Exclude:
	if [ -n "$OPT_EXCLUDE" ]; then
		HOSTS_LIST_TO_VERIFY=$(echo "$HOSTS_LIST_TO_VERIFY" | tr ' ' '\n' | grep -v "$OPT_EXCLUDE" )
	fi

	# Include:
	if [ -n "$OPT_INCLUDE" ]; then
		HOSTS_LIST_TO_VERIFY=$(echo "$HOSTS_LIST_TO_VERIFY" | tr ' ' '\n' | grep "$OPT_INCLUDE" )
	fi

	# Build line
	for host in $HOSTS_LIST_TO_VERIFY; do
		if [ -n "$OPT_LOGIN" ]; then
			host="$OPT_LOGIN@$host"
		fi
		if [ "$OPT_FORCE" != "true" ]; then
			echo " - $host"
		fi
		HOSTS_LIST="$host $HOSTS_LIST"
	done

	HOSTS_LIST="$( echo "${HOSTS_LIST}" | sed -e 's/\ $//' )"

else
	echo "** Aucune machine trouvee! **"
	exit 1
fi
unset HOSTS_LIST_TO_VERIFY







## Ready ?
# ========
if [ "$OPT_FORCE" != "true" ]; then
	echo ''
	echo -n "Pour continuer taper OUI: "
	read ANSWER
	echo "-----------------"
else
	ANSWER="OUI"
fi




## Let's go..
# ===========
if [ "$ANSWER" == "OUI" ];then
	CMD="$CSSH ${OPT_CSSH} $OPT_COMMANDE $HOSTS_LIST"
	eval "${CMD}"
else
	echo "* Annuler *"
fi
