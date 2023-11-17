class puppet_cage::compare(

  $reportemail

){

  include puppet_cage

  $cagedir = $puppet_cage::cagedir 
  $listfile = "$puppet_cage::cagedir/listfile" 

  # Set --email option if asked for
  if $reportemail { $reportOpt = "--email $reportemail" } 
  else { $reportOpt = ""  }

  # Compare the caged and real dirs
  #
  #   Notice that we run it once to see if there're differences (no changes will be logged
  #   by Puppet), and, if there're changes, we run it again as the proper 'exec' resource.
  #   The latter is the one causing a 'Changed' status in Puppetboard and sending a report
  #   by email. If we don't use the 'onlyif', every comparison would cause a 'Changed'
  #   status even if the comparison shows no diffs (because an 'exec' was run).
  exec{ "$cagedir/puppet-cage-do-cmp.sh -f $listfile $reportOpt $cagedir":
    path   => ['/usr/bin'],
    onlyif => "echo \"! $cagedir/puppet-cage-do-cmp.sh -f $listfile $cagedir\" | bash",
  }

}
