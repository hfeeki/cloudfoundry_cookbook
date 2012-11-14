#
# Cookbook Name:: router
# Recipe:: default
#
# Copyright 2011, VMware
#
node.set[:deployment][:name] = "router"
node.set[:deployment][:home] = File.join(node[:cloudfoundry][:home], ".deployments", node[:deployment][:name])
node.set[:deployment][:config_path] = File.join(node[:deployment][:home], "config")
node.set[:deployment][:info_file] = File.join(node[:deployment][:config_path], "deployment_info.json")
node.set[:nats_server][:host]= node[:ipaddress].to_s 

if Chef::Config[:solo]
        Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else 
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

template File.join(node[:deployment][:config_path],node[:router][:config_file]) do
  source "router.yml.erb"
  owner node[:deployment][:user]
  mode 0644
  action :create
end

bash "start "+  " #{node[:deployment][:name]} " do
  user "root" 
  cwd "/tmp"
  ignore_failure true 
  code <<-EOH
  nohup /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n #{node[:deployment][:name]} restart
  EOH
end

bash "status "+  " #{node[:deployment][:name]} " do
  user "root"
  cwd "/tmp"
  ignore_failure true
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n #{node[:deployment][:name]} status 
  EOH
end

end 
