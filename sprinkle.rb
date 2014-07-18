package :build_essentials do
  description 'Build Essesntial Package'
  apt %w(build-essential), :sudo => true do 
    pre :install, 'apt-get update'
  end
end

package :ruby_dependencies do
  description 'Ruby Virtual Machine Build Dependencies'
  apt %w( bison zlib1g-dev libssl-dev libreadline-dev libncurses5-dev file ), :sudo => true
end

package :ruby do
  description 'Ruby'
  version '2.1.2'
  source "http://cache.ruby-lang.org/pub/ruby/2.1/ruby-#{version}.tar.gz", :sudo => true 
  requires :ruby_dependencies
  verify do
    has_file '/usr/local/bin/ruby'
  end
end

package :nmap do
  description 'nmap'
  version '6.46'
  source "http://nmap.org/dist/nmap-#{version}.tar.bz2", :sudo => true
  requires :build_essentials
  verify do
    has_file '/usr/local/bin/nmap'
  end
end

package :metasploit_dependencies do
  description 'Metasploit Dependencies'
  apt %w(libreadline-dev libssl-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev subversion git-core autoconf postgresql pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev vncviewer libyaml-dev), :sudo => true
end

package :rubygem_dependencies do
  description 'dependencies for ruby gems'
  apt %w(libxslt1-dev libxml2-dev), :sudo => true
end

package :ruby_gems do
  description 'common gems'
  #unlike apt which passes an array this should be a string
  gem 'brakeman rails builder mechanize httparty nmap-parser rtf rubyXL wirble'
  requires :ruby
end

package :metasploit do
  description 'Metasploit Framework'
  runner ['git clone https://github.com/rapid7/metasploit-framework.git', 'mv metasploit-framework/ /opt/'] do
    post :install, 'BUNDLE_GEMFILE=/opt/metasploit-framework/Gemfile bundle install'
  end
  requires :metasploit_dependencies

end


policy :ruby, :roles => :test do
  requires :build_essentials
  #requires :ruby_dependencies
  #requires :ruby, :version => "2.1.2"
  #requires :metasploit_dependencies
  #requires :nmap
  #requires :ruby_dependencies
  #requires :ruby, :version => "2.1.2"
  #requires :ruby_gems
  requires :metasploit
end


deployment do
  delivery :ssh do
    roles :test => '192.168.153.132'
    use_sudo
    user 'vagrant'
    keys 'c:\Users\rorym.SECINTERNAL\.vagrant.d\insecure_private_key'
  end

  source do
    prefix    '/usr/local'
    archives  '/usr/local/sources'
    builds    '/usr/local/build'
  end
end