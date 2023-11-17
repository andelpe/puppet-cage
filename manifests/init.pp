
class puppet_cage(

  $cagedir = "/root/puppet-cage",
  $listfile = "$cagedir/listfile",

){

    include puppet_cage::base
}

# Module to confine files in a cage area, instead of at their real target locations.
