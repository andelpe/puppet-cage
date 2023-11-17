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
   echo "   --dry"
   echo "   -e, --email <address>"
   echo "   -f, --file <listfile>"
}

show_help(){
   echo "Copies files from the Puppet cage the real filesystem location.

If the listfile is not specified with -f, then \$cagedir/listfile is used.

If --dry is used, the files are not really copied.

If --email option is used, the output is also sent by email.
"
}
  

########################### MAIN #################################

args=`getopt -l "usage,help,verbose,email:,file:,dry" uhve:f:  $*`

if [ $? != 0 ]; then
   usage
   exit 1
fi

# Default values
verb=false
verbOpt=""
dry=false
email=""
listfile=""

for i do
  case "$i" in
     -h|--help) shift; echo; show_help; echo; usage; echo; options; exit 0;;
     -u|--usage) shift; usage; exit 0;;
     -v|--verbose) shift; verb=true; verbOpt="-v";;
     --dry) shift; dry=true;;
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
filesdir="$cagedir/files"

if ! [ "$listfile" ]; then
    listfile="$cagedir/listfile"
fi

if ($verb); then
    err "-- Comparing files at cage area: $cagedir/files"
    err "-- Files list is: $listfile"
fi

out=$(while read fn; do
    if ! (diff -q ${filesdir}${fn} $fn >/dev/null); then 
        if ! ($dry); then 
            if ($verb); then  echo "cp ${filesdir}${fn} $fn"; fi
            /bin/cp ${filesdir}${fn} $fn
        else 
            echo "  Would:  cp ${filesdir}${fn} $fn"
        fi
    else
        if ($verb); then  echo "${filesdir}${fn} and $fn are equal"; fi
    fi
done < $listfile)

# if email
if [ "$email" ]; then  
    if [ $rc -ne 0 ]; then  
        err "-- Sending report email to $email"
        echo "$out" | mail -s "Puppet cage apply: $(hostname -s)" "$email"
    fi
fi

echo "$out"

