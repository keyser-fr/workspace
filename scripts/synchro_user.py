#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, os
import getopt

class Sync_User(object):
    """Permet de synchroniser les repertoires /home/<user> sur le repertoire de backup (/mnt/backup/home)"""

    user_homedir = None
    # Constante de VERSION du programme
    global VERSION
    VERSION = '1.0'

#############################################################################
    def __init__(self, user_homedir=None):
        self.user_homedir = user_homedir

#############################################################################

    def get_Homedir_User(self):
        return(self.user_homedir)

#############################################################################

    def set_Homedir_User(self, user_homedir):
        self.user_homedir = user_homedir

#############################################################################

    def launcher_Actions(self, user_homedir):

        login="login"
        cmd = 'rsync -e ssh -av --temp-dir=/{login}/var/tmp/rsync --progress --delete-after /home/{user_homedir}/ {login}@localhost:/mnt/backup/home/{user_homedir}'.format(
            login=login,
            user_homedir=user_homedir)
        print('Commande a executer')
        print(cmd)

        # On execute la commande
        # proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        # cmd_retval = subprocess.call(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        # # cmd_stdout, cmd_stderr = proc.communicate()
        # cmd_stdout = cmd_stdout.strip(" \n")

        # if (cmd_retval == 0):
        #     print('Transfert OK')
        # else:
        #     print('Transfert KO')

#############################################################################
#############################################################################

def usage():
    print("Usage: %s --user <user_homedir>" % (sys.argv[0]))
    print("Example: %s --user 'toto'" % (sys.argv[0]))

#############################################################################

def check_syntax():

    try:
        opts, args = getopt.getopt(sys.argv[1:], 'hv', ['help', 'version', 'user='])
    except getopt.GetoptError, err:
        print(str(err))
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage()
            sys.exit(0)

        elif opt in ('-v', '--version'):
            print('%s version: %s' % (sys.argv[0], VERSION))
            sys.exit(0)

        elif opt in ('--user'):
            global user
            user = arg

        else:
            assert False, 'Unhandled option'

#############################################################################

if __name__ == "__main__":
    check_syntax()

    if (len(sys.argv) != 3):
        usage()
        sys.exit(2)
    else:
        try:
            import pwd
            pw = pwd.getpwnam(user)
            login = pw.pw_name
            uid = pw.pw_uid
            # print(login, uid)
            print('OK for user: %s' % (user))
        except:
            print("Unknown user: %s" % (user))
            sys.exit(255)

        Sync_User_instance = Sync_User(user)
        Sync_User_instance.launcher_Actions(user)

    sys.exit(0)
