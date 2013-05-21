action :add do
  vhname   = new_resource.vhname
  template = new_resource.template
  options  = new_resource.options

  options[:access_log_filename] = "#{vhname}_access.log"
  options[:error_log_filename] = "#{vhname}_error.log"

  template "/etc/nginx/sites-available/#{vhname}" do
    source template
    mode "0644"
    variables ({
      :options => options
    })  
  end
end

action :enable do
  vhname = new_resource.vhname

  link "/etc/nginx/sites-enabled/#{vhname}" do
    to "/etc/nginx/sites-available/#{vhname}"
  end
end

action :disable do
 vhname = new_resource.vhname

 link "/etc/nginx/sites-enabled/#{vhname}" do
    action :delete
    only_if "test -L /etc/nginx/sites-available/#{vhname}"
  end
end

action :delete do
  vhname = new_resource.vhname

  file "/etc/nginx/sites-available/#{vhname}" do
    action :delete
  end
end
