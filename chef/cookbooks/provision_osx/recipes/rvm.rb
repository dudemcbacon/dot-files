#
#
# rvm install
#
#

execute "install rvm" do
  command "curl -sSL https://get.rvm.io | bash -s stable --ignore-dotfiles"
  cwd "/Users/#{node['current_user']}"
  creates "/Users/#{node['current_user']}/.rvm/"
end

bash "setup rvm requirements.....This is going to take a while; go grab some coffee, trust me." do
  cwd "/Users/#{node['current_user']}"
  creates "/Users/#{node['current_user']}/.rvm/ive_installed_bitch_requirements"
  code <<-EOH
    STATUS=0
    source "/Users/#{node['current_user']}/.rvm/scripts/rvm"
    rvm requirements|| STATUS=1
    touch /Users/#{node['current_user']}/.rvm/ive_installed_bitch_requirements
    exit $STATUS
  EOH
end

bash "setup rvm 2.2" do
  cwd "/Users/#{node['current_user']}"
  creates "/Users/#{node['current_user']}/.rvm/ive_installed_bitch_210"
  code <<-EOH
    STATUS=0
    source "/Users/#{node['current_user']}/.rvm/scripts/rvm"
    rvm install 2.2 || STATUS=1
    touch /Users/#{node['current_user']}/.rvm/ive_installed_bitch_210
    exit $STATUS
  EOH
end

