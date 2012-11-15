#
# Cookbook Name:: start_service_mongodb
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
node.set[:deployment][:name] = "mongodb_service"
node.set[:deployment][:home] = File.join(node[:cloudfoundry][:home], ".deployments", node[:deployment][:name])
node.set[:deployment][:config_path] = File.join(node[:deployment][:home], "config")
node.set[:deployment][:info_file] = File.join(node[:deployment][:config_path], "deployment_info.json")



if Chef::Config[:solo]
        Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
        cf_id_node = node['cf_session']['cf_id']
        m_nodes_nats = search(:node, "role:cloudfoundry_nats_server_ng AND cf_id:#{cf_id_node}")
       while m_nodes_nats.count < 1
        Chef::Log.warn("Waiting for nats .... I am sleeping 7 sec")
        sleep 7
        m_nodes_nats = search(:node, "role:cloudfoundry_nats_server_ng AND cf_id:#{cf_id_node}")
       end
       m_nodes_nats.each {|k|
        if (k['cf_session']['cf_id'] == node['cf_session']['cf_id']) then
              node.set['nats_server']['user']= k['nats_server']['user']
              node.set['nats_server']['password']= k['nats_server']['password']
              node.set['nats_server']['host']= k['ipaddress']
              node.set['nats_server']['port']= k['nats_server']['port']
        end
       }


        cf_id_node = node['cf_session']['cf_id']
        m_nodes_cc = search(:node, "role:cloudfoundry_controller_nv AND cf_id:#{cf_id_node}")
       while m_nodes_cc.count < 1
        Chef::Log.warn("Waiting for cc .... I am sleeping 7 sec")
        sleep 7
        m_nodes_cc = search(:node, "role:cloudfoundry_controller_nv AND cf_id:#{cf_id_node}")
       end
       m_nodes_cc.each {|k|
        if (k['cf_session']['cf_id'] == node['cf_session']['cf_id']) then
              node.set['cloud_controller']['service_api_uri'] =  "" + k['ipaddress'].to_s + ":9022"   #['cloud_controller']['service_api_uri']
        end
       }

 m_nodes_mdb = search(:node, "role:cloudfoundry_mongodb_service_nv AND cf_id:#{cf_id_node}")
 node.set[:mongodb_node][:index] = m_nodes_mdb.count



end


case node['platform']
when "ubuntu"

    configs = ["mongodb_backup.yml", "mongodb_node.yml", "mongodb_worker.yml", "mongodb_gateway.yml"]
    configs.each do |config|
     template File.join(node[:deployment][:config_path],config ) do
      source "#{config}.erb"
      owner node[:deployment][:user]
      mode "0644"
      action :create
     end
    end 

    confs = ["mongodb_backup.cron"]
    
    confs.each do |config|
     template File.join(node[:deployment][:config_path],config ) do
      source "#{config}.erb"
      owner node[:deployment][:user]
      mode "0644"
      action :create
     end
    end

else
  Chef::Log.error("Installation of mmongodb not supported on this platform.")
end




bash "start MongoDB Service"   do
  user "root" 
  cwd "/tmp" 
  code <<-EOH
  nohup /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n #{node[:deployment][:name]} start 
  EOH
end
