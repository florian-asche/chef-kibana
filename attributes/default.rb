# The method used to install kibana.  `git` will clone the git repo,
# `file` will download from elasticsearch.org
# git is not really supported since the move to java based server.
default['kibana']['install_type'] = 'file' # git | file
default['kibana']['version'] = '6.1.3-linux-x86_64' # must match version number of kibana being installed

# Values to use for git method of installation
default['kibana']['git']['url'] = 'https://github.com/elasticsearch/kibana'
default['kibana']['git']['branch'] = 'v6.1.3'
default['kibana']['git']['type'] = 'sync' # checkout | sync
default['kibana']['git']['config'] = 'kibana/config.js' # relative path of config file

# Values to use for file method of installation
default['kibana']['file']['type'] = 'tgz' # zip | tgz

default['kibana']['file']['url'] = nil # calculated based on version, unless you override this
default['kibana']['file']['checksum'] = "19caf0c29db6c98c8bf5194deba0de7ce065cc10bc2175af6f4efdbc3b88e2a7" # sha256 ( shasum -a 256 FILENAME )
default['kibana']['file']['config'] = 'config/kibana.yml' # relative path of config file

# this is only used by the recipe.  if you use the LWRPs
# (which you should) then install java from your own recipe.
default['kibana']['install_java'] = true

# Which webserver to use, and webserver options.
default['kibana']['webserver'] = 'nginx' # nginx or apache
default['kibana']['webserver_hostname'] = node.name
default['kibana']['webserver_aliases'] = [node['ipaddress']]
default['kibana']['webserver_listen'] = node['ipaddress']
default['kibana']['webserver_port'] = 80
default['kibana']['webserver_scheme'] = 'http://'

# parent directory of install_dir.  This is required because of the `file` method.
default['kibana']['install_path'] = '/opt'

# the actual installation directory of kibana. If using the `file` method this should be left as is.
default['kibana']['install_dir'] = "#{node['kibana']['install_path']}/kibana"

# used to configure proxy information for the webserver to proxy ES calls.
default['kibana']['es_server'] = '127.0.0.1'
default['kibana']['es_port'] = '9200'
default['kibana']['es_role'] = 'elasticsearch_server'
default['kibana']['es_scheme'] = 'http://'

# user to install kibana files as.  if left blank will use the default webserver user.
default['kibana']['user'] = 'kibana'

## config template location and variables.
# Kibana is served by a backend server. This controls which port to use.
default['kibana']['config']['server.port'] = 5601
default['kibana']['config']['server.host'] = 'localhost'
default['kibana']['config']['server.name'] = 'kibana'
# Kibana uses and index in Elasticsearch to store saved searches, visualizations
# and dashboard. It will create an new index if it doesn't already exist.
default['kibana']['config']['kibana.index'] = 'kibana-int'
# The default application to load.
default['kibana']['config']['kibana.defaultAppId'] = 'discover'
# include quote inside this next variable if not using window.location style variables...
# e.g.  = "'http://elasticsearch.example.com:9200'"
#default['kibana']['config']['elasticsearch.url'] = "http://127.0.0.1:9200"  # Automatic generated, but you can override if you need to
# Time in milliseconds to wait for responses from the back end or elasticsearch.
# This must be > 0
default['kibana']['config']['elasticsearch.requestTimeout'] = 60000
# Time in milliseconds for Elasticsearch to wait for responses from shards.
# Note this should always be lower than "request_timeout".
# Set to 0 to disable (not recommended).
default['kibana']['config']['elasticsearch.shardTimeout'] = 30000
# Set logging destination
default['kibana']['config']['logging.dest'] = '/var/log/kibana/kibana.log'
# Set verbose logging
default['kibana']['config']['logging.verbose'] = false

# nginx variables
default['kibana']['nginx']['install_method'] = 'package'
default['kibana']['nginx']['template'] = 'kibana-nginx_file.conf.erb'
default['kibana']['nginx']['template_cookbook'] = 'kibana_lwrp'
default['kibana']['nginx']['enable_default_site'] = false
default['kibana']['nginx']['install_method'] = 'package'

# Apache variables.
default['kibana']['apache']['template'] = 'kibana-apache_file.conf.erb'
default['kibana']['apache']['template_cookbook'] = 'kibana_lwrp'
default['kibana']['apache']['enable_default_site'] = false

# Service options, passed as is to the runit_service resource
# (see https://github.com/chef-cookbooks/runit#parameter-attributes)
default['kibana']['service']['options'] = {}
