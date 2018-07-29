name 'kibana_lwrp'
maintainer 'John E. Vincent'
maintainer_email 'lusis.org+github.com@gmail.com'
license 'Apache 2.0'
description 'Installs/Configures kibana'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version '4.1.0'

supports 'ubuntu'
supports 'debian'

depends 'libarchive', '~> 1.0.0' 
depends 'git'
depends 'compat_resource'

depends 'ohai'

depends 'chef_nginx'
depends 'apache2'

depends 'ark'
depends 'java'
depends 'runit'
