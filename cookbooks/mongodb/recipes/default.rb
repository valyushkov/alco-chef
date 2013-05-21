log("[mongodb] - Converge mongodb") {level :warn}

service 'mongodb' do
  supports :restart => true
  action :nothing
end

node[:mongodb][:packages].each do |pkg_name, version|
  package pkg_name do
    version version
    action :install
  end
end

directory node[:mongodb][:config][:dbpath] do
  owner node[:mongodb][:user]
  group node[:mongodb][:group]
  mode "0755"
  action :create
end

directory node[:mongodb][:logpath] do
  owner node[:mongodb][:user]
  group node[:mongodb][:group] 
  mode "0755"
  action :create
end

template "/etc/mongodb.conf" do
  source "mongodb.conf.erb"
  owner "root"
  group "root"
  mode "0644"

  notifies :restart, resources(:service => 'mongodb'), :immediately
end
