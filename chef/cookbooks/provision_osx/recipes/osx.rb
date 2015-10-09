# Install RVM Rubies
include_recipe 'provision_osx::rvm'

# TODO: Figure out why this doesn't work
#rvm_ruby "ruby-2.1"
#rvm_ruby "ruby-2.2"
#rvm_default_ruby "ruby-2.2"

# Install Homebrew Packages
include_recipe 'homebrew::default'
homebrew_tap 'caskroom/cask'

%w{ brew-cask tmux zsh }.each do |pkg|
  package pkg do
    action :install
  end
end

# Install OSX Casks
homebrew_cask "caffeine"
homebrew_cask "cinch"
homebrew_cask "disk-inventory-x"
homebrew_cask "google-chrome"
homebrew_cask "iterm2"
homebrew_cask "limechat"
homebrew_cask "skype"
homebrew_cask "steam"
# this requires some funkiness with sudo privs
#homebrew_cask "vagrant"

# Run OSX Config Script
cookbook_file "/tmp/osx.sh" do
  source "osx.sh"
  mode 0755
end

execute "configure osx" do
  creates '/tmp/osx_done'
  command 'sh /tmp/osx.sh'
end
