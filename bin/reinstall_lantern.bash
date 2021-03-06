#!/usr/bin/env bash

# Remove the old one.
$(dirname $0)/ssh_cloudmaster.py 'sudo salt "fp-*" cmd.run "apt-get remove lantern --assume-yes"'

# For some reason, /opt/lantern/jre is not removed on uninstall.  Let's wipe
# all of /opt/lantern just to be on the safe side.
$(dirname $0)/ssh_cloudmaster.py 'sudo salt "fp-*" cmd.run "rm -rf /opt/lantern"'

# Re-apply the salt state so Lantern is installed again.  We have configured
# salt to restart the lantern service when this happens.
$(dirname $0)/ssh_cloudmaster.py 'sudo salt "fp-*" state.highstate'
