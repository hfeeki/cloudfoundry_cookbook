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


 






#TODO ??? 
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








#Search runtimes availible on this platforme 
if Chef::Config[:solo]
        Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else 
        
        
        node.set['cloud_cloud_controller']['database']['host'] = node['ipaddress']
        cf_id_node = node['cf_session']['cf_id']
        m_nodes_nats = search(:node, "role:cloudfoundry_nats_server AND cf_id:#{cf_id_node}")

       while m_nodes_nats.count < 1 
        Chef::Log.warn("Waiting for nats .... I am sleeping 7 sec")
        sleep 7
        m_nodes_nats = search(:node, "role:cloudfoundry_nats_server AND cf_id:#{cf_id_node}")        
       end

  
       m_nodes_nats.each {|k| 
        if (k['cf_session']['cf_id'] == node['cf_session']['cf_id']) then 
              node.set['nats_server']['user']= k['nats_server']['user']
              node.set['nats_server']['password']= k['nats_server']['password']
              node.set['nats_server']['host']= k['ipaddress']
              node.set['nats_server']['port']= k['nats_server']['port']

        end
       }

        cf_id_node = 12 # for testing 
        m_nodes_dea = search(:node, "role:cloudfoundry_dea_* AND cf_id:#{cf_id_node}")
        tmp = Hash.new

        m_nodes_dea.each do |m_node_dea|
        tmp = tmp.merge(m_node_dea['cloudfoundry_dea']['runtimes'])
        end

        Chef::Log.warn("runtimes.merge(tmp['runtimes']" + tmp.to_s)
        node.set['searched_data']['runtimes']= tmp
        node.set['cloud_controller']['service_api_uri'] = node.ipaddress.to_s + ":9022"

end 


#Make ressearch to générate correct runtimes.yml.erb 
template node[:cloud_controller][:runtimes_file] do
   path File.join(node[:deployment][:config_path], node[:cloud_controller][:runtimes_file])
   source "runtimes.yml.erb"
   owner node[:deployment][:user]
   mode 0644
end



template "vcap_redis.conf" do
  path File.join(node[:deployment][:config_path], "vcap_redis.conf")
  source "vcap_redis.conf.erb"
  owner node[:deployment][:user]
  mode 0644
end

template "vcap_redis" do
  path File.join("", "etc", "init.d", "vcap_redis")
  source "vcap_redis.erb"
  owner node[:deployment][:user]
  mode 0755
end

service "vcap_redis" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end


bash "start_CC_HM" do
  user "root" 
  cwd "/tmp" 
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n cloud_controller-health_manager start 
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




