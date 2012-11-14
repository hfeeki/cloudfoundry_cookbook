#
# Cookbook Name:: cloud_controller
# Recipe:: default
#
# Copyright 2011, VMware
#
#

 Chef::Log.info("-------------------------------------------------------------------------")
 Chef::Log.info("Path = " +  File.join(node[:deployment][:config_path],node[:cloud_controller][:config_file]).to_s)
 Chef::Log.info("node[:cloud_controller][:builtin_services] = " + node[:cloud_controller][:builtin_services].to_s)
 Chef::Log.info("node[:deployment][:user] =" + node[:deployment][:user].to_s ) 

node.set[:deployment][:name] = "cloud_controller-health_manager"
node.set[:deployment][:home] = File.join(node[:cloudfoundry][:home], ".deployments", node[:deployment][:name])
node.set[:deployment][:config_path] = File.join(node[:deployment][:home], "config")
node.set[:deployment][:info_file] = File.join(node[:deployment][:config_path], "deployment_info.json")

node.set[:deployment][:domain] = node['cloud_controller']['domain']


#Search runtimes availible on this platforme 
if Chef::Config[:solo]
        Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else 
        
        
        node.set['cloud_cloud_controller']['database']['host'] = node['ipaddress']
        cf_id_node = node['cf_session']['cf_id']
        m_nodes_nats = search(:node, "role:cloudfoundry_nats_server_ng AND cf_id:#{cf_id_node}")
        Chef::Log.warn("cf_id_node = " + cf_id_node.to_s)


       while m_nodes_nats.count == 0 
        Chef::Log.warn("Waiting for nats .... I am sleeping 7 sec")
        sleep 7
        m_nodes_nats = search(:node, "role:cloudfoundry_nats_server_ng AND cf_id:#{cf_id_node}")        
       end
       Chef::Log.warn("Nats found ip = " + m_nodes_nats.first.to_s)
              k = m_nodes_nats.first   
              node.set['nats_server']['user']= k['nats_server']['user']
              node.set['nats_server']['password']= k['nats_server']['password']
              node.set['nats_server']['host']= k['ipaddress']
              node.set['nats_server']['port']= k['nats_server']['port']


       

#        cf_id_node = 12 # for testing 
        m_nodes_dea = search(:node, "role:cloudfoundry_dea_* AND cf_id:#{cf_id_node}")
        #tmp = Hash.new
        tmp = Array.new
        m_nodes_dea.each do |m_node_dea|
        #tmp = tmp.merge(m_node_dea['dea']['runtimes'])
        tmp = tmp + m_node_dea['dea']['runtimes']
        end
         tmp = tmp.uniq
        Chef::Log.warn("runtimes.merge(tmp['runtimes']" + tmp.to_s)
        node.set['searched_data']['runtimes']= tmp

        

node.set['dea']['frameworks'] = Array.new

tmp.each do |runtime|
  case runtime
  when "ruby18", "ruby19"
    node.set['dea']['frameworks'] =  ["sinatra","rails3"] + node['dea']['frameworks']
  when "java", "java7"
    node.set['dea']['frameworks'] = ["spring"] + node['dea']['frameworks']
  when "node04", "node06", "node08"
    node.set['dea']['frameworks'] = ["node"] + node['dea']['frameworks']
  when "php"
    node.set['dea']['frameworks'] = ["php"] + node['dea']['frameworks']
  when "python2"
    node.set['dea']['frameworks'] = ["python"] + node['dea']['frameworks']
  end
end
 node.set['dea']['frameworks'] = node['dea']['frameworks'].uniq







#        node.set['cloud_controller']['service_api_uri']  = "" +  node.ipaddress.to_s + ":9022"
        node.save

end   

  Chef::Log.warn("node['cloud_controller']['service_api_uri'] = " + node['cloud_controller']['service_api_uri'].to_s)
node.set['ccdb']['host']= node.ipaddress.to_s
node.set['vcap_redis']['host']= node.ipaddress.to_s
  Chef::Log.warn("node[:deployment][:config_path] === " + node[:deployment][:config_path].to_s)

template  File.join(node[:deployment][:config_path], node[:cloud_controller][:config_file]) do
#  path File.join(node[:deployment][:config_path], node[:cloud_controller][:config_file])
  source "cloud_controller.yml.erb"
  owner node[:deployment][:user]
  mode 0644
  action :create
#  builtin_services = []
#  case node[:cloud_controller][:builtin_services]
#  when Array
#    builtin_services = node[:cloud_controller][:builtin_services]
#  when Hash
#    builtin_services = node[:cloud_controller][:builtin_services].keys
#  when String
#    builtin_services = node[:cloud_controller][:builtin_services].split(" ")
#  else
#    Chef::Log.info("Input error: Please specify cloud_controller builtin_services as a list, it has an unsupported type #{node[:cloud_controller][:builtin_services].class}")
#    exit 1
#  end
#  variables({
#    :builtin_services => builtin_services
#  })
end



template "/etc/postgresql/8.4/main/postgresql.conf" do
#   path File.join(node[:deployment][:config_path], node[:cloud_controller][:runtimes_file])
   source "postgresql.conf.erb"
   owner node[:deployment][:user]
   mode 0644
   action :create
end


bash "restart_postgres_database" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  /etc/init.d/postgresql-8.4 restart
  EOH
end


template File.join(node[:deployment][:config_path],node[:cloud_controller][:runtimes_file]) do
#   path File.join(node[:deployment][:config_path], node[:cloud_controller][:runtimes_file])
   source "runtimes.yml.erb"
   owner node[:deployment][:user]
   mode 0644
   action :create
end


bash "Delete stagers" do
  user "root"
  cwd "#{File.join(node[:deployment][:config_path], "staging")}"
  interpreter "bash"
  ignore_failure true
  code <<-EOH
  cd "#{File.join(node[:deployment][:config_path], "staging")}"
  rm ./*
  EOH
end



staging_dir = File.join(node[:deployment][:config_path], "staging")
node[:cloud_controller][:staging].each_pair do |framework, config|
 if node['dea']['frameworks'].include?framework
  template config do
    path File.join(staging_dir, config)
    source "#{config}.erb"
    owner node[:deployment][:user]
    mode 0644
  end
 end

end

template File.join(node[:deployment][:config_path],"vcap_redis.conf") do
#  path File.join(node[:deployment][:config_path], "vcap_redis.conf")
  source "vcap_redis.conf.erb"
  owner node[:deployment][:user]
  mode 0644
  action :create
end

template File.join(node[:deployment][:config_path],"vcap_redis") do
#  path File.join("", "etc", "init.d", "vcap_redis")
  source "vcap_redis.erb"
  owner node[:deployment][:user]
  mode 0755
  action :create
end

template File.join(node[:deployment][:config_path],node[:health_manager][:config_file]) do
#  path File.join(node[:deployment][:config_path], node[:health_manager][:config_file])
  source "health_manager.yml.erb"
  owner node[:deployment][:user]
  mode 0644
  action :create
end



template File.join(node[:deployment][:config_path],"uaa.yml") do
#  path File.join(node[:deployment][:config_path], node[:health_manager][:config_file])
  source "uaa.yml.erb"
  owner node[:deployment][:user]
  mode 0644
  action :create
end

template File.join(node[:deployment][:config_path],node[:stager][:config_file]) do
  source "stager.yml.erb"
  owner node[:deployment][:user]
  mode 0644
  action :create
end

template File.join(node[:deployment][:config_path],node[:stager][:platform]) do
  source "platform.yml.erb"
  owner node[:deployment][:user]
  mode 0644
  action :create
end




service "vcap_redis" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end


bash "start_CC_HM" do
  user "root"
  cwd "/tmp"
  interpreter "bash"
  ignore_failure true
  code <<-EOH
  nohup /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n #{node[:deployment][:name]} restart
  EOH
end

bash "status_CC_HM" do
  user "root" 
  cwd "/tmp" 
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n #{node[:deployment][:name]} status
  EOH
end




#Make research to add the list of frameworks 
#staging_dir = File.join(node[:deployment][:config_path], "staging")
#node[:cloud_controller][:staging].each_pair do |framework, config|
#  template config do
#    path File.join(staging_dir, config)
#    source "#{config}.erb"
#    owner node[:deployment][:user]
#    mode 0644
#  end
#end




