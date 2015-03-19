#!/bin/bash
#
# How to use:
# From directory {root}/out/target/common/docs/online-sac run:
#    $ ./stageme.sh <server number>
#
# For example, to stage on
# https://sourceandroid-staging13.googleplex.com/
# run
#    $ ./stageme.sh 13
#

echo  'Please run this script from the output directory where it lives' \
  ' out/target/common/docs/online-sac'
echo ' '

# Go up a directory to stage content
cd ..

# Edit the app.yaml file to upload to the specified server.
sed 's/staging[0-9]*$/staging'$1'/' online-sac/app.yaml >  .temp

# Confirm app.yaml content
echo 'Here is the revised app.yaml for your staging server:'
cat .temp

while true; do
read -p "Is this app.yaml OK to stage? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Copy in new app.yaml content
cp .temp online-sac/app.yaml
rm .temp

# Stage the data on the server.
$AE_STAGING update online-sac

# Return to original directory
cd online-sac

echo 'Your staged content is available at https://sourceandroid-staging'$1'.googleplex.com/'
