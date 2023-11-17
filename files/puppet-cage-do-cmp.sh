#!/bin/bash

############### CONSTANTS (configurable settings) ##################


#################### FUNCTIONS #######################
err(){
  echo -e "$*" >&2
}

usage(){
  echo "Usage: `basename $0` [opts] <cagedir>"
  echo "       `basename $0` -u | -h"
}

options(){
   echo "Options summary:"
   echo "   -u, --usage"
   echo "   -h, --help"
   echo "   -v, --verbose"
   echo "   -e, --email <address>"
   echo "   -f, --file <listfile>"
}

show_help(){
   echo "Compares files at the Puppet cage and at the real filesystem location.

If the listfile is not specified with -f, then \$cagedir/listfile is used.

If --email option is used, the output is also sent by email.
"
}
  

########################### MAIN #################################

args=`getopt -l "usage,help,verbose,email:,file:" uhve:f:  $*`

if [ $? != 0 ]; then
   usage
   exit 1
fi

# Default values
verb=false
verbOpt=""
email=""
listfile=""

for i do
  case "$i" in
     -h|--help) shift; echo; show_help; echo; usage; echo; options; exit 0;;
     -u|--usage) shift; usage; exit 0;;
     -v|--verbose) shift; verb=true; verbOpt="-v";;
     -e|--email) shift; email="$1"; shift;;
     -f|--file) shift; listfile="$1"; shift;;
  esac
done

# Check that there is at least one argument
if ! [ "$1" ];then
  err "Not enough input arguments!"
  usage
  exit 1
fi

cagedir="$1"

if ! [ "$listfile" ]; then
    listfile="$cagedir/listfile"
fi

if ($verb); then
    err "-- Comparing files at cage area: $cagedir/files"
    err "-- Files list is: $listfile"
fi

out=$($cagedir/puppet-cage-cmp.py $verbOpt -d $cagedir/files $listfile)
rc=$?

info1="
For more information, please log into $(hostname -s) and run:
   
    $cagedir/puppet-cage-cmp.py -v -d $cagedir/files $listfile
"
info2="
To apply changes, please run, at $(hostname -s):

    $cagedir/puppet-cage-apply.sh -f $listfile  $cagedir
"

if [ $rc -ne 0 ]; then  
    if [ "$email" ]; then  
        err "-- Sending report email to $email"
        echo -e "$out\n$info1\n$info2" | mail -s "Puppet cage diffs found: $(hostname -s)" "$email"
    else
        echo -e "$out\n$info2"
    fi
else
    echo -e "$out"
fi

exit $rc

