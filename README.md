# puppet-module-puppet-cage

## Overview

This module wraps around puppet file resources, so that they aren't synchronized to their
target paths at the agent's host filesystem, but rather to a location within a pre-defined
cage directory. The idea is that puppet does not directly modify very important and
potentially risky files, but modifies a replica of the files (caged files) instead. An
administrator must actively enforce the changes from the cage to the real filesystem
locations when desired.

If a puppet-managed file should be at `/etc/dcache/layouts/gaeds001.conf`, puppet will
actually manage a path like `/root/puppet-cage/etc/dcache/layouts/gaeds001.conf` instead.

In addition, the module also allows for the periodic execution of a script that compares
the contents of files within /root/puppet-cage, and their counterparts in the real target
locations, so that a report comparing file differences is sent by email (if no difference
is found, no email is sent).


## Usage

In the manifests that would normally instruct Puppet to handle certain files at the agent
host, the `file` resource should be replaced by the `puppet_cage::cagedfile` resource, and
the normal file arguments should be all included in a unique hash arg, called `fileargs`.

E.g., the following:
```
file { "/etc/dcache/layouts/gaeds001.conf":
    ensure  => file,
    owner   => 'dcache',
    group   => 'dcache',
    [...]
}
```

Should be replaced by:
```
puppet_cage::cagedfile { "/etc/dcache/layouts/gaeds001.conf":
   fileargs => {
     ensure  => file,
     owner   => 'dcache',
     group   => 'dcache',
     [...]
}
```

For the previously described comparison script to be run by Puppet agent, you should
include the class `puppet_cage::compare`, in the node's catalog, optionally with an email
address for a report to be sent. E.g. in Hiera:
```
classes:
  - puppet_cage::compare

puppet_cage::compare::reportemail:  admins@example.com
```

If the `reportemail` variable is set, a report with the found differences will be sent by
enmail. Otherwise, Puppet will run the comparison script and return a non-zero exit code
(error) if differences are found, but no report will be sent.

Finally, if the admin deciedes that the files within the cage should be really copied to
their respective target paths at the agent's filesystem (i.e., changes applied), the
following script should be run at the agent:
```
$cagedir/puppet-cage-apply.sh
```

By default, this is:
```
/root/puppet-cage/puppet-cage-apply.sh
```

The same can be achieved by including the class `puppet_cage::apply` (again, with an
optional email report), e.g.:

```
classes:
 - puppet_cage::apply

puppet_cage::apply::reportemail: admins@example.com
```

But if you do this, notice that either you remove it afterwards, or the apply script will
be run every time puppet is run; i.e., puppet files will always end up in the final target
paths, and, thus, you'll be defeating the very purpose of this module.

