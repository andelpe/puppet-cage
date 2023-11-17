define puppet_cage::cagedfile(
    Hash $fileargs = {}
) {

  include puppet_cage

  $basedir = "$puppet_cage::cagedir/files"
  $listfile = $puppet_cage::listfile

  # Recurse on path dirs and create them within cagedir
  $folders = split($title, "/")
  $folders.each |$index, $folder| {
      $path_so_far = join($folders[0, $index+1], "/")
      if ($path_so_far != $title){
          if (! defined(File["${basedir}${path_so_far}"])) {
              file { "${basedir}${path_so_far}": ensure => directory, }
          }
      }
  }

  # Now, define the file (with just the same args passed to 'cagedfile')
  file {"${basedir}${title}":  
      * => $fileargs
  }

  # Ensure that 'path' is included within $listfile
  file_line { "${listfile}_${title}":
      path => "$listfile",
      line => "$title",
  }

}

