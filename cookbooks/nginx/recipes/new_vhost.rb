include_recipe "nginx::default"

runit_service "nginx" do
  action :enable
end

directory "/storage/nginx" do
  owner "www-data"
  group "www-data"
  mode 00755
  recursive true
  action :create
end


node[:nginx][:new_vhost].each do |vhost_name, vhost_params|
  log("[nginx::new_vhost] - Converge nginx virtualhost #{vhost_name}") { level :warn }
  nginx_virtualhost vhost_name do
    params = Mash.new()
    %w[http_options upstreams vhost_options locations http_array].each do |key|
      if vhost_params.has_key?(key)
        params[key] = vhost_params[key]
      else
        params[key] = Mash.new()
      end
    end

    template "new_vhost.erb"
    options params
    action :add
  end

  if vhost_params.has_key?('htpasswd')
    vhost_params['htpasswd'].each do |name, params|
      params['users'].each do |username, password|
        nginx_htpasswd username do
          file "/etc/nginx/#{name}"
          password password
          action :add
        end
      end
    end
  end

  nginx_virtualhost vhost_name do
    action :enable
  end
end
