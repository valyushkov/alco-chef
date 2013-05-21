default[:mongodb][:packages] = {
  "mongodb-server" => nil,
  "mongodb-clients" => nil,
  "mongodb-dev" => nil,
  "python-pymongo" => nil
  }

default[:mongodb][:user] = "mongodb"
default[:mongodb][:group] = "mongodb"
default[:mongodb][:logpath] = "/var/log/mongodb/"

default[:mongodb][:config][:dbpath] = "/var/lib/mongodb"
default[:mongodb][:config][:logpath] = "#{node[:mongodb][:logpath]}/mongodb.log"
default[:mongodb][:config][:port] = "27017"
default[:mongodb][:config][:bind_ip] = "127.0.0.1"
