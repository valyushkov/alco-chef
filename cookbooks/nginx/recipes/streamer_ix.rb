log("[nginx::default] - Converge service: nginx") {level :warn}

node[:nginx][:depends][:packages].each do |pkg_name, version|
  package pkg_name do
    version version
    action :install
  end
end


template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode  "0644"
end

template "/etc/nginx/sites-available/status.conf" do
  source "status.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/nginx/sites-available/streamer-cdn.conf" do
  source "streamer-cdn.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

link "/etc/nginx/sites-enabled/status" do
  to "/etc/nginx/sites-available/status.conf"
  action :create
end

link "/etc/nginx/sites-enabled/streamer-cdn" do
  to "/etc/nginx/sites-available/streamer-cdn.conf"
  action :create
end

runit_service "nginx" do
  action :add
  run_script_template "sv_run.erb"
  log_run_script_template "sv_log_run_#{node[:nginx][:logger_type]}.erb"
  options = Mash.new
end

link "/etc/nginx/sites-enables/default" do
  action :delete
end

file "/etc/nginx/sites-available/default" do
  action :delete
end


directory "#{node[:nginx][:cache_temp_path]}" do
  owner "www-data"
  group "www-data"
  mode "0644"

  recursive true
end

directory "#{node[:nginx][:local_cache_path]}" do
  owner "www-data"
  group "www-data"
  mode "0644"

  recursive true
end