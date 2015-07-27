read -p "Press any key to start..."

if ! [ -a /Users/`whoami`/.ssh/id_rsa ]; then
  echo "You should probably set up your private key."
  exit 1
fi

if [ ! -d /Library/Developer ]; then
  printf "%s\n" $'
  You need to have Xcode with Command Line Tools installed before you can
  continue.

  Do one of the following:

    1. git --version
    2. click install # this one is only about 300mbs, and takes a couple minutes
  
    - OR -

    1. Go to the App Store and install Xcode. # this one is only about 3 Gigs, and takes about an hour....
    2. Start Xcode.
    3. Click on Xcode in the top left corner of the menu bar and click on
       Preferences.
    4. Click on the Downloads tab.
    5. Click on the Install button next to Command Line Tools.'
    exit 1
fi

if ! [ -a /usr/bin/chef-solo ]; then
  curl -L https://www.opscode.com/chef/install.sh && sudo bash ./install.sh -P chefdk
fi

if ! [ -a /Users/`whoami`/chef-solo ]; then
  mkdir -p /Users/`whoami`/chef-solo
  echo "root = File.absolute_path(File.dirname(__FILE__))

    file_cache_path root
    cookbook_path root + '/cookbooks'" > /Users/`whoami`/chef-solo/solo.rb

  echo '{
      "run_list": [ "recipe[homebrew]","recipe[dmg]","recipe[provision]" ]
}' > /Users/`whoami`/chef-solo/solo.json
fi
