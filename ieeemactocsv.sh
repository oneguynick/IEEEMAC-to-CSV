#!/bin/bash
ieee="ieee-mac-oui.csv"
# do not change these 2 tmp variables:
tmpa="a"
tmpb="b"

# download MA-L assignments (contains placeholders for MA-M and MA-S)
wget -N http://standards.ieee.org/develop/regauth/oui/oui.txt >/dev/null 2>&1
# download MA-M assignments
wget -N http://standards.ieee.org/develop/regauth/oui28/mam.txt >/dev/null 2>&1
# download MA-S assignments
wget -N http://standards.ieee.org/develop/regauth/oui36/oui36.txt >/dev/null 2>&1

# remove MA-M and MA-S placeholders in MA-L (oui.txt) file
# remove (hex) fields as it's superfluous
grep "(hex)" oui.txt  | grep -v "public listing" | awk '{$2=""; print}' > $tmpa
# get rest of the ranges from the other files (MA-M and MA-S) and append
grep "(hex)" mam.txt  | awk '{$2=""; print}' >> $tmpa
grep "(hex)" oui36.txt  | awk '{$2=""; print}' >> $tmpa

# UPPERCASE everything makes searches easier
tr 'a-z' 'A-Z' < $tmpa >$tmpb

# clean up = get rid of spaces and replace with , separator
# replace - MAC octet separator with :
sed -i '1i\'"Vendor_MAC,Manufacturer" $tmpb
sed -e 's/  /,/' -re 's/([0-9]+)-([0-9]+)-/\1:\2:/' < $tmpb > $ieee

# move new file in proper Splunk lookup location and make an old copy
copy_old $ieee
move_new $ieee

# final clean up just in case
clean_up >/dev/null 2>&1
