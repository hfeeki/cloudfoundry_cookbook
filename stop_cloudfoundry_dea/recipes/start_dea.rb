#Search runtimes availible on this platforme 
if Chef::Config[:solo]
        Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
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
end



node['dea']['component_name'].each do |cn|
  case cn
  when "dea_ruby"
    node.set['dea']['runtimes'] = ["ruby18", "ruby19"]
    node.set['dea']['frameworks'] =  ["sinatra"]
  when "dea_java"
    node.set['dea']['runtimes'] = ["java", "java7"]
    node.set['dea']['frameworks'] = ["spring"]
  when "dea_node"
    node.set['dea']['runtimes'] = ["node04", "node06", "node08"]
    node.set['dea']['frameworks'] = ["node"]
  when "dea_php"
    node.set['dea']['runtimes'] = ["php"]
    node.set['dea']['frameworks'] = ["php"]
  when "dea_python"
    node.set['dea']['runtimes'] =  ["python2"]
    node.set['dea']['frameworks'] = ["python"]
  end
end



template File.join(node[:deployment][:config_path],node[:dea][:config_file]) do
  source "dea.yml.erb"
  owner node[:deployment][:user]
  mode 0644
  action :create 
end



bash "start " + node['dea']['component_name']  do
  user "root" 
  cwd "/tmp" 
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n #{node['dea']['component_name']} start 
  EOH
end

