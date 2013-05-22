default[:alco][:packages] = {}

default[:alco][:app_root] = "/var/www/reestr"
default[:alco][:user] = "devel"
default[:alco][:group] = "developers"
default[:alco][:vhost] = "alco"
default[:alco][:nginx][:vhost_name] = node[:fqdn]
