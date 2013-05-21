require 'fileutils'

recipe_name = "runit::service"
logger = Chef::Log

action :add do

  necessary_files = []
  necessary_dirs = []

  service_name = new_resource.service_name
  run_script_template       = new_resource.run_script_template
  finish_script_template    = new_resource.finish_script_template

  log_run_script_template   = new_resource.log_run_script_template
  log_config_template       = new_resource.log_config_template

  # Если TYPE_script_template не задан, пытаемся найти его автоматически в
  # sv/sv_TYPE_#{service_name}.erb

  run_script_template = "sv/sv_run_#{service_name}.erb" if run_script_template.nil?
  log_run_script_template = "sv/sv_log_run_#{service_name}.erb" if log_run_script_template.nil?

  # verm666. 2012.07.16
  # Для значения по-умолчанию не используется директива default из ресурса,
  # что бы можно было использовать значение переменной `service_name`
  log_directory             = new_resource.log_directory || "/storage/log/#{service_name}"

  control_t_script_template = new_resource.control_t_script_template
  options                   = new_resource.options

  files_to_view = new_resource.files_to_view
  files_to_watch = new_resource.files_to_watch
  urls_to_view = new_resource.urls_to_view

  necessary_files << "/etc/sv/#{service_name}/run" if run_script_template
  necessary_files << "/etc/sv/#{service_name}/finish" if finish_script_template
  necessary_files << "/etc/sv/#{service_name}/log/run" if log_run_script_template
  necessary_files << "/etc/sv/#{service_name}/control/t" if control_t_script_template

  necessary_dirs << "/etc/sv/#{service_name}/log"
  necessary_dirs << "/etc/sv/#{service_name}/control" if control_t_script_template

  files_to_view.each do |file|
    necessary_files << "/etc/sv/#{service_name}/runit-man/files-to-view/#{::File.basename(file)}"
  end

  files_to_watch.each do |file|
    necessary_files << "/etc/sv/#{service_name}/runit-man/files-to-watch/#{::File.basename(file)}"
  end

  urls_to_view.each do |url|
    necessary_files << "/etc/sv/#{service_name}/runit-man/urls-to-view/#{url.gsub(/[\/:]/, "_")}.url"
  end

  if not files_to_view.empty?
    necessary_dirs << "/etc/sv/#{service_name}/runit-man/files-to-view"
  end

  if not urls_to_view.empty?
    necessary_dirs << "/etc/sv/#{service_name}/runit-man/urls-to-view"
  end

  if not files_to_watch.empty?
    necessary_dirs << "/etc/sv/#{service_name}/runit-man/files-to-watch"
  end

  if not files_to_view.empty? or not urls_to_view.empty?
    necessary_dirs << "/etc/sv/#{service_name}/runit-man"
  end

  current_files = []
  current_dirs = []
  ::Dir.glob("/etc/sv/#{service_name}/**/**/*") do |f|
    next if f =~ /^.*supervise.*$/

    if ::File.directory? f
      current_dirs << f
      next
    end

    current_files << f
  end

  orphaned_files = current_files - necessary_files
  orphaned_dirs = current_dirs - necessary_dirs

  orphaned_files.each do |f|
    Chef::Log.warn("REMOVE orphaned file: #{f}")
    ::File.unlink(f)
  end

  orphaned_dirs.each do |d|
    Chef::Log.warn("REMOVE orphaned dir: #{d}")
    ::Dir.rmdir(d)
  end

  logger.warn("[#{recipe_name}] - Converge service: #{service_name}")
  # Node attributes are read-only when you do not specify which precedence level to set. To set an attribute use code like `node.default["key"] = "value"'
  # в 11 шефе node.default[:runit][:services] - mash, в 10 - node::atribute like array
  node.default[:runit][:services].merge!({service_name => "added" })

  directory "/etc/sv/#{service_name}" do
    owner "root"
    group "root"
    mode  "0755"
  end

  directory "/etc/sv/#{service_name}/supervise" do
    owner "root"
    group "root"
    mode  "0755"
  end

  directory "/etc/sv/#{service_name}/log" do
    owner "root"
    group "root"
    mode  "0755"
  end

  directory "/etc/sv/#{service_name}/log/supervise" do
    owner "root"
    group "root"
    mode  "0755"
  end

  template "/etc/sv/#{service_name}/run" do
    owner "root"
    group "root"
    mode  "0744"
    source run_script_template
    variables ({
      :options => options
    })  
  end

  if finish_script_template
    template "/etc/sv/#{service_name}/finish" do
      owner "root"
      group "root"
      mode  "0744"
      source finish_script_template
      variables ({
        :options => options
      }) 
    end
  end

  if control_t_script_template
    directory "/etc/sv/#{service_name}/control" do
      owner "root"
      group "root"
      mode "0744"
    end

    template "/etc/sv/#{service_name}/control/t" do
      owner "root"
      group "root"
      mode "0744"
      source control_t_script_template
      variables ({
        :options => options
      })
    end
  end

  if log_config_template && log_directory
    directory log_directory do
      owner "root"
      group "root"
      mode "0755"

      recursive true
    end

    if log_config_template.index("\n")
      if not ::Dir.exists? log_directory
        FileUtils.mkdir_p log_directory
      end
      ::File.open("#{log_directory}/config", 'w') do |f|
        f.write(log_config_template)
      end
    else
      template "#{log_directory}/config" do
        source log_config_template
        variables ({
          :options => options
        })  
      end
    end
  end

  template "/etc/sv/#{service_name}/log/run" do
    owner "root"
    group "root"
    mode  "0744"
    source log_run_script_template
    variables ({
      :options => options
    }) 
  end

  if not urls_to_view.empty?
    directory "/etc/sv/#{service_name}/runit-man/urls-to-view" do
      owner "root"
      group "root"
      mode "0755"

      recursive true
    end

    urls_to_view.each do |url|
      file "/etc/sv/#{service_name}/runit-man/urls-to-view/#{url.gsub(/[\/:]/, "_")}.url" do
        content url
        action :touch
      end
    end
  end

  if not files_to_view.empty?
    directory "/etc/sv/#{service_name}/runit-man/files-to-view" do
      owner "root"
      group "root"
      mode "0755"

      recursive true
    end

    files_to_view.each do |file|
      link "/etc/sv/#{service_name}/runit-man/files-to-view/#{::File.basename(file)}" do
        to file
      end
    end
  end

  if not files_to_watch.empty?
    directory "/etc/sv/#{service_name}/runit-man/files-to-watch" do
      owner "root"
      group "root"
      mode "0755"

      recursive true
    end

    files_to_watch.each do |file|
      link "/etc/sv/#{service_name}/runit-man/files-to-watch/#{::File.basename(file)}" do
        to file
      end
    end
  end
end

action :enable do
  service_name = new_resource.name

  link "/etc/service/#{service_name}" do
    to "/etc/sv/#{service_name}"
    action :create
  end

  node.default[:runit][:services].merge!({service_name => "enabled" })
end

action :disable do
  service_name = new_resource.name

  link "/etc/service/#{service_name}" do
    action :delete
  end

  node.default[:runit][:services].merge!({service_name => "disabled" })
end

action :restart do
  service_name = new_resource.name

  execute "sv restart #{service_name}" do
    command "sv restart #{service_name}"
    action :run
    only_if "sv status #{service_name}"
  end
  node.default[:runit][:services].delete(service_name)
end
