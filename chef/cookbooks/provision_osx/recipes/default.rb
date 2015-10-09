#
# Main Provision Recipe File
#

if platform_family?('mac_os_x')
  include_recipe 'provision_osx::osx'
end

# Install Bundler
%w{bundler}.each do |g|
  gem_package "#{g}" do
    action :install
  end
end


