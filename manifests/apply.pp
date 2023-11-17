class puppet_cage::compare(

  $reportemail

){

  include puppet_cage

  $cagedir = $puppet_cage::cagedir 
  $listfile = "$puppet_cage::cagedir/listfile" 

  # Set --email option if asked for
  if $reportemail { $reportOpt = "--email $reportemail" } 
  else { $reportOpt = ""  }

  # Run the apply script
  exec{ "$cagedir/puppet-cage-apply.sh -f $listfile $reportOpt $cagedir":
    path => ['/usr/bin'],
  }

}
