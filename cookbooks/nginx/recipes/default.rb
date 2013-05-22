log("[nginx::default] - Converge service: nginx") {level :warn}

node[:nginx][:depends][:packages].each do |pkg_name, version|
  package pkg_name do
    version version
    action :install
  end
end

directory "/usr/local/nginx/uwsgi_temp" do
  owner "www-data"
  group "www-data"
  mode "0644"

  recursive true
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode  "0644"
end

runit_service "nginx" do
  action :add
  run_script_template "sv_run.erb"
  log_run_script_template "sv_log_run_#{node[:nginx][:logger_type]}.erb"
  options = Mash.new
end

link "/etc/nginx/sites-enabled/default" do
  action :delete
end

file "/etc/nginx/sites-available/default" do
  action :delete
end
