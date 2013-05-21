default[:nginx][:logger_type] = "svlogd"

default[:nginx][:user] = "www-data"

default[:nginx][:worker_processes] = "4"
default[:nginx][:worker_rlimit_nofile] = "8192"
default[:nginx][:worker_connections] = "8192"

default[:nginx][:status_port] = "11311"

default[:nginx][:depends][:packages] = {
  "nginx-runit" => nil
}

default[:nginx][:new_vhost] = {}

default[:nginx][:upstream_url] = "" # set in role
default[:nginx][:cache_temp_path] = "" # set in role
default[:nginx][:local_cache_path] = "" # set in role
