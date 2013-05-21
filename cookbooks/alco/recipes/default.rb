log("[alco:default] - Converge service alco") { level :warn }

execute "apt-update" do
  command "apt-get update"
  action :nothing
end

service "nginx" do
  action :disable
end

# Packages
cookbook_file "/etc/apt/sources.list.d/squeeze.list" do
  source "squeeze.list"
  owner "root"
  group "root"
  mode "0644"
  notifies :run, resources(:execute => "apt-update")
end

node[:alco][:packages].each do |pkg_name, version|
  package pkg_name do
    version version
    action :install
    options "-y --force-yes"
  end
end

execute "coffee_install" do
  command "npm -g install coffee-script-redux"
  not_if "npm -g list 2>/dev/null | grep -q coffee-script-redux"
  action :nothing
end

# APP_ROOT
directory node[:alco][:app_root] do
  owner node[:alco][:user]
  group node[:alco][:group]
  mode "0755"

  recursive true
end

# Nginx
nginx_virtualhost node[:alco][:vhost] do
  template "nginx.vhost.erb"
  options ({})
  action :add
end

# Runit
runit_service "alco" do
  run_script_template "sv_run_alco.erb"
  log_run_script_template "sv_log_run_alco.erb"
  action :add
end


