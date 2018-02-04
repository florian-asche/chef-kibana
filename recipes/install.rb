#
# Cookbook Name:: kibana
# Recipe:: install
#
# Copyright 2013, John E. Vincent
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Gather installation type (can be git or file)
install_type = node['kibana']['install_type']

# Gather ip-adress of elasticsearch
unless Chef::Config[:solo]
  es_server_results = search(:node, "roles:#{node['kibana']['es_role']} AND chef_environment:#{node.chef_environment}")
  unless es_server_results.empty?
    node.override['kibana']['es_server'] = es_server_results[0]['ipaddress']
  end
end

# Gather webserver install product
webserver = 'nginx' # make nginx a default choice
webserver = node['kibana']['webserver'] if !node['kibana']['webserver'].empty?

# Create User
if node['kibana']['user'].empty?
  if !node['kibana']['webserver'].empty?
    kibana_user = node[webserver]['user']
  else
    kibana_user = 'nobody'
  end
else
  kibana_user = node['kibana']['user']
  kibana_user kibana_user do
    name kibana_user
    group kibana_user
    home node['kibana']['install_dir']
    action :create
  end
end

# Install kibana
kibana_install 'kibana' do
  user kibana_user
  group kibana_user
  install_dir node['kibana']['install_dir']
  install_type install_type
  action :create
end

# Set some more variables
docroot = "#{node['kibana']['install_dir']}/current/kibana"
kibana_config = "#{node['kibana']['install_dir']}/current/#{node['kibana'][install_type]['config']}"
node.override['kibana']['config']['elasticsearch.url'] = "#{node['kibana']['es_scheme']}#{node['kibana']['es_server']}:#{node['kibana']['es_port']}" unless node['kibana']['config']['elasticsearch.url']

# generate yml kibana configuration from json (converted)
file ::File.join(kibana_config) do
  content YAML.dump(node['kibana']['config'].to_hash)
  owner kibana_user
  group kibana_user
  mode '0644'
  notifies :restart, "runit_service[kibana]"
end

# Install service
# TODO: https://supermarket.chef.io/cookbooks/runit weiche einbauen für service oder runit
if install_type == 'file'
  include_recipe 'runit::default'

  runit_service 'kibana' do
    options(
      user: kibana_user,
      home: "#{node['kibana']['install_dir']}/current"
    )
    cookbook 'kibana_lwrp'

    node['kibana']['service']['options'].each do |option_name, option_value|
      send(option_name, option_value)
    end

    subscribes :restart, "template[#{kibana_config}]", :delayed
  end

end

# Setup webserver
kibana_web 'kibana' do
  type lazy { node['kibana']['webserver'] }
  docroot docroot
  es_server node['kibana']['es_server']
  kibana_port node['kibana']['config']['server.port']
  template node['kibana'][webserver]['template']
  template_cookbook node['kibana'][webserver]['template_cookbook']
  not_if { node['kibana']['webserver'] == '' }
end
