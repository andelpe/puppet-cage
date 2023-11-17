#!/usr/bin/env python

####   IMPORTS   ####
from __future__ import print_function, division
import sys, os
from argparse import ArgumentParser, Action, RawTextHelpFormatter
import difflib

####   CONSTANTS   ####
DEF_CAGEDIR = "/root/puppet-cage/files"

####   FUNCTIONS   ####

def equalFiles(fna, fnb, verb=False):
    """
    Given two filenames, 'fna' and 'fnb', if their contents are equal,
    return True. If they differ, return False.
    """
    try:
        with open(fna) as fa:
            with open(fnb) as fb:
                if not verb:
                    while True:
                        la = fa.readline()
                        lb = fb.readline()
                        if la != lb: return False
                        if not la:
                            if lb: return False
                            else:  return True
                        if not lb: return False
                else:
                    lines_fa = fa.readlines()
                    lines_fb = fb.readlines()
                    difflines = difflib.unified_diff(lines_fa, lines_fb, fna, fnb)

                    first = True
                    for x in difflines:
                        if first: 
                            print("\n\n@@@@@ FILES {0} and {1} differ".format(fna, fnb))
                            first = False
                        print(x.strip())

                    # Now, if first is still True, is that there was no diff...
                    if first:
                        print("\n\n@@@@@ FILES {0} and {1} are equal".format(fna, fnb))
                        return True
                    else:
                        return False

    except IOError:
        # One of the files does not exist... check both
        exists_a = True
        try:  os.stat(fna)
        except FileNotFoundError:
            exists_a = False

        exists_b = True
        try:  os.stat(fnb)
        except FileNotFoundError:
            exists_b = False

        if exists_a and (not exists_b): 
            if verb:  print("@@@ FILE {0} does not exist!".format(fnb))
            return False

        if exists_b and (not exists_a): 
            if verb:  print("@@@ FILE {0} does not exist!".format(fna))
            return False
            

def compareFiles(cagedir, fns, verb=False):
    rc = 0
    for fna in fns:
        fnb = cagedir + '/' + fna
        if verb: 
            if not equalFiles(fna, fnb, verb): rc = 1
        else:
            if not equalFiles(fna, fnb): 
                print("Files {0} and {1} differ".format(fna, fnb))
                rc = 1
    return rc


####   MAIN   ####
def main():
    """
     Performes the main task of the script (invoked directly).
     For information on its functionality, please call the help function.
    """
    
    # Options
    helpstr = """
Utility to compare files at the Puppet cage and at the real filesystem location.

If any file is different 1 is returned, and the files that differ shown. Otherwise 0 is
returned, and the ouput is null.

If -v is used, unidiff is shown for different files, and an informative messages for equal
files.
"""

    # Create parser with general help information
    parser = ArgumentParser(description=helpstr, formatter_class=RawTextHelpFormatter)

    # Set the version
    parser.add_argument('--version', action='version', version='%(prog)s 2.0')

    # Option verbose ('store_true' option type)
    helpstr = "Be verbose (show additional information)"
    parser.add_argument( "-v", "--verbose", dest="verb", help=helpstr, action="store_true")

    # Option usage 
    class UsageAction(Action):
        def __init__(self, option_strings, dest, nargs=None, **kwargs):
            Action.__init__(self, option_strings, dest, nargs=0, **kwargs)
        def __call__(self, parser, namespace, values, option_string=None):
            parser.print_usage()
            sys.exit(0)
    helpstr = "Show usage information"
    parser.add_argument("-u", "--usage", help=helpstr, action=UsageAction)
    def usage():
        parser.print_usage() 

    helpstr = "Use specified dir as cagedir, instead of default"
    parser.add_argument( "-d", "--cagedir", dest="cagedir", help=helpstr, action="store", default=DEF_CAGEDIR)

    # Positional arguments
    parser.add_argument("listfile", help="File with the list of files to compare (one per line)")

    # Do parse options
    args = parser.parse_args()

    # Shortcut for verbose
    verb = args.verb
    
    #### REAL MAIN ####
    with open(args.listfile) as flist:
        fns = [x.strip() for x in flist.readlines()]

    rc = compareFiles(args.cagedir, fns, verb)
        
    # Exit successfully
    return rc


###    SCRIPT    ####
if __name__=="__main__":
    sys.exit(main())
