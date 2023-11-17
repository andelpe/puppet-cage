class puppet_cage::base(

  $cagedir = $puppet_cage::cagedir, 
  $listfile = $puppet_cage::listfile,

){

  # Ensure basedirs exist
  $basedir = "$cagedir/files"
  file { $cagedir: ensure => directory, }
  file { $basedir: ensure => directory, }

  # Ensure the listfile exists
  file { $listfile: ensure => file, }

  # Ensure we have the scripts and the file list within the cagedir
  file { "$cagedir/puppet-cage-cmp.py":
      source => "puppet:///modules/puppet_cage/puppet-cage-cmp.py",
      mode   => "0700"
  }
  file { "$cagedir/puppet-cage-do-cmp.sh":
      source => "puppet:///modules/puppet_cage/puppet-cage-do-cmp.sh",
      mode   => "0700"
  }
  file { "$cagedir/puppet-cage-apply.sh":
      source => "puppet:///modules/puppet_cage/puppet-cage-apply.sh",
      mode   => "0700"
  }

}
