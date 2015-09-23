#This is a Sprinkle(https://github.com/sprinkle-tool/sprinkle) script for automating
#build of a security testing linux build (based on Ubuntu)
#Sources used 
#https://github.com/madmantm/ubuntu-pentest-tools/blob/master/ubuntu-pentest-tools.sh
#http://www.darkoperator.com/installing-metasploit-in-ubunt/
# Java From https://launchpad.net/~webupd8team/+archive/ubuntu/java

#this is a cut of a script for setting up a local laptop instead of over a network
#you need to get ruby working first so no packages for that
#Easiest way is likely to use rvm (http://rvm.io)
#You will also need build-essential already installed for gem setup
#To run this you need to use sudo or rvmsudo
#e.g. rvmsudo sprinkle -v -s sprinkle-local.rb

#At the moment I'm assuming this will be run with sudo (as opposed to running as root)


#This variable is used later for chown commands
$user = ENV['SUDO_USER']

#Absolute Essentials for Docker and other lightweight Envs
package :basics do
	description 'Basic install packages'
	apt %w(python-software-properties software-properties-common sudo) do
		pre :install, 'apt-get update'
		pre :install, 'apt-get -y upgrade'
	end
end

#This is probably already installed but just in case
package :build_essentials do
  description 'Build Essential Package'
  apt %w(build-essential), :sudo => true
  requires :basics
  verify do
    has_apt 'build-essential'
  end
end

package :wireshark do
  description 'Wireshark Packet Sniffer'
  apt %w(wireshark), :sudo => true
  verify do
    has_apt 'wireshark'
  end
end

package :nmap do
  description 'nmap'
  version '6.47'
  source "http://nmap.org/dist/nmap-#{version}.tar.bz2", :sudo => true
  requires :build_essentials
  requires :general_dependencies
  verify do
    has_file '/usr/local/bin/nmap'
  end
end

package :general_dependencies do
  description 'useful packages for general use and installation'
  apt %w(git-core subversion vim wget), :sudo => true
  verify do
    has_apt 'git-core'
    has_apt 'subversion'
    has_apt 'vim'
    has_apt 'wget'
    has_apt 'unzip'
  end
end

package :network_clients do
  description 'network clients for various protocols (e.g. SMB, NFS)'
  apt %w(smbclient nfs-common rsh-client mysql-client-core-5.6), :sudo => true
  verify do
    has_apt 'smbclient'
    has_apt 'nfs-common'
    has_apt 'rsh-client'
    has_apt 'mysql-client-core-5.6'
  end
end

package :network_tools do
  description 'Tools for network lookups (e.g. dns/whois)'
  apt %w(whois snmp), :sudo => true
  verify do
    has_apt :whois
    has_apt :snmp
  end
end

package :metasploit_dependencies do
  description 'Metasploit Dependencies'
  apt %w(libreadline-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev autoconf postgresql pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev vncviewer libyaml-dev), :sudo => true
  verify do
    has_apt 'libreadline-dev'
    has_apt 'libpq5'
    has_apt 'libpq-dev'
    has_apt 'libreadline5'
    has_apt 'libsqlite3-dev'
    has_apt 'libpcap-dev'
  end
end

package :rubygem_dependencies do
  description 'dependencies for ruby gems'  
  apt %w(libxslt1-dev libxml2-dev), :sudo => true
  verify do
    has_apt 'libxslt1-dev'
    has_apt 'libxml2-dev'
  end
end

package :ruby_gems do
  description 'common gems'
  requires :mechanize
  requires :httparty
  requires :nmap_parser
  requires :rtf
  requires :rubyXL
  requires :wirble
  requires :builder
  requires :bundler
  requires :rails
  requires :brakeman
end

package :mechanize do
  description 'mechanize gem'
  gem 'mechanize'
  verify do 
    has_gem 'mechanize'
  end
end

package :httparty do
  description 'httparty gem'
  gem 'httparty'
  verify do
    has_gem 'httparty'
  end
end

package :nmap_parser do
  description 'nmap-parser gem'
  gem 'nmap-parser'
  verify do
    has_gem 'nmap-parser'
  end
end

package :rtf do
  description 'rtf gem'
  gem 'rtf'
  verify do 
    has_gem 'rtf'
  end
end

package :rubyXL do
  description 'rubyXL gem'
  gem 'rubyXL'
  verify do
    has_gem 'rubyXL'
  end
end

package :wirble do
  description 'wirble gem'
  gem 'wirble'
  verify do
    has_gem 'wirble'
  end
end

package :builder do
  description 'builder gem'
  gem 'builder'
  verify do
    has_gem 'builder'
  end
end

package :bundler do
  description 'ruby bunder'
  gem 'bundler'
  verify do
    has_executable 'bundle'
  end
end

package :rails do
  description 'ruby on rails'
  gem 'rails'
  verify do
    has_executable 'rails'
  end
end

package :brakeman do
  description 'brakeman static analysis'
  gem 'brakeman'
  verify do
    has_executable 'brakeman'
  end
end

package :metasploit do
  description 'Metasploit Framework'
  runner ['git clone --depth=1 https://github.com/rapid7/metasploit-framework.git', 'mv metasploit-framework/ /opt/'] do
    post :install, 'rvm install ruby-1.9.3-p547'
    post :install, 'rvm use 1.9.3'
    post :install, 'BUNDLE_GEMFILE=/opt/metasploit-framework/Gemfile bundle install'
    post :install, "chown -R #{$user}:#{$user} /opt/metasploit-framework"
  end
  requires :ruby_gems
  requires :general_dependencies
  requires :metasploit_dependencies
  requires :java
  verify do 
    has_file '/opt/metasploit-framework/msfconsole'
  end
end

package :testing_scripts do
  description 'Rorys testing scripts repo'
  runner ['git clone --depth=1 https://github.com/raesene/TestingScripts.git', 'mv TestingScripts/ /opt/'] do
    post :install, 'BUNDLE_GEMFILE=/opt/TestingScripts/Gemfile bundle install'
    post :install, "chown -R #{$user}:#{$user} /opt/TestingScripts"
  end
  requires :ruby_gems
  requires :general_dependencies
  verify do
    has_file '/opt/TestingScripts/nmapautoanalyzer.rb'
  end
end

package :arachni_dependencies do
  description 'Dependencies for Arachni'
  apt %w(libcurl4-openssl-dev libyaml-dev), :sudo => true
  verify do
    has_apt 'libcurl4-openssl-dev'
    has_apt 'libyaml-dev'
  end
end

package :arachni do
  description 'arachni web app scanner'
  runner ['git clone --depth=1 https://github.com/Arachni/arachni.git', 'mv arachni/ /opt/'] do
    post :install, 'BUNDLE_GEMFILE=/opt/arachni/Gemfile bundle install'
    post :install, "chown -R #{$user}:#{$user} /opt/arachni"
  end
  requires :ruby_gems
  requires :general_dependencies
  requires :arachni_dependencies
  verify do
    has_executable '/opt/arachni/bin/arachni'
  end
end

package :nikto_dependencies do
  description 'dependencies for nikto'
  apt %w(libnet-ssleay-perl), :sudo => true
  verify do
    has_apt 'libnet-ssleay-perl'
  end
end

package :nikto do 
  description 'nikto CGI scanner'
  runner ['git clone --depth=1 https://github.com/sullo/nikto.git', 'mv nikto/ /opt/'] do
    post :install, "chown -R #{$user}:#{$user} /opt/nikto"
  end
  verify do
    has_file '/opt/nikto/program/nikto.pl'
  end
  requires :nikto_dependencies
end

package :testing_tools do
  description 'testing tools in the ubuntu Apt repo'
  apt %w(onesixtyone), :sudo => true
  verify do
    has_apt :onesixtyone
  end
end

package :seclists do
  runner ['git clone --depth=1 https://github.com/danielmiessler/SecLists.git', 'mv SecLists/ /opt/']
  verify do
    has_directory '/opt/SecLists/'
  end
end

package :docker do
  runner ['wget -qO- https://get.docker.com/ | sh'], :sudo => true
  verify do
    has_executable 'docker'
  end
end

#non-interactive hack from - http://askubuntu.com/questions/190582/installing-java-automatically-with-silent-option 
package :java do 
  description 'Oracle Java via the webupd8 repo'
  apt %w(oracle-java7-installer), :sudo => true do
    pre :install, 'add-apt-repository ppa:webupd8team/java'
    pre :install, 'apt-get update'
    pre :install, 'echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections'
    pre :install, 'echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections'
  end
  verify do
    has_file ' /usr/lib/jvm/java-7-oracle/jre/bin/java'
  end
end

package :zap do
  description 'OWASP ZAP Proxy'
  runner ['wget -q https://github.com/zaproxy/zaproxy/releases/download/2.4.2/ZAP_2.4.2_Linux.tar.gz', 'tar -xzvf ZAP_2.4.2_Linux.tar.gz', 'mv ZAP_2.4.2 /opt/ZAP']
  verify do
    has_file '/opt/ZAP/zap.sh'
  end
  requires :java
end

package :beef do
  description 'Beef XSS Framework'
  runner ['wget -q https://github.com/beefproject/beef/archive/beef-0.4.6.1.zip', 'unzip -qq beef-0.4.6.1.zip', 'mv beef-beef-0.4.6.1/ /opt/beef/'] do
    post :install, 'rvm install ruby-1.9.3-p547'
    post :install, 'rvm use 1.9.3'
    post :install, 'BUNDLE_GEMFILE=/opt/beef/Gemfile bundle install'
  end
  verify do
    has_file '/opt/beef/beef'
  end
  requires :ruby_gems
  requires :general_dependencies
end

package :apache_directory_studio do
  description 'GUI LDAP Query App'
  runner ['wget -q http://mirror.vorboss.net/apache/directory/studio/2.0.0.v20150606-M9/ApacheDirectoryStudio-2.0.0.v20150606-M9-linux.gtk.x86_64.tar.gz', 'tar -xzf ApacheDirectoryStudio-2.0.0.v20150606-M9-linux.gtk.x86_64.tar.gz', 'mv ApacheDirectoryStudio /opt/']
  verify do
    has_file '/opt/ApacheDirectoryStudio/ApacheDirectoryStudio'
  end
  requires :java
end

package :hoppy do
  description 'HTTP Options Scanner'
  runner ['wget -q https://labs.portcullis.co.uk/download/hoppy-1.8.1.tar.bz2','tar -xjf hoppy-1.8.1.tar.bz2','mv hoppy-1.8.1 /opt/hoppy/']
  verify do
    has_file '/opt/hoppy/hoppy'
  end
end

#per http://developer.android.com/sdk/installing/index.html?pkg=tools
package :android_sdk_prereqs do
  description 'Android SDK prereqs for Ubuntu'
  apt %w(libncurses5:i386 libstdc++6:i386 zlib1g:i386), :sudo => true do
    pre :install, 'dpkg --add-architecture i386'    
    pre :install, 'apt-get update'
  end
end

#Kind of useless for now as you'll still need to get the platforms
#tricky to automate due to dumb license accepting screens
package :android_sdk do
  description 'Android SDK'
  version = '23.0.2'
  runner ["wget http://dl.google.com/android/android-sdk_r#{version}-linux.tgz", "tar -xzf android-sdk_r#{version}-linux.tgz", "mv android-sdk-line /opt/"] do
    post :install, "chown -R #{$user}:#{$user} /opt/android-sdk-line"
  end
  requires :android_sdk_prereqs
end

package :input_rc do
  description 'case insensitive tab completion'
  file "/home/#{$user}/.inputrc", :content => File.read('personalisations/.inputrc') do
    post :install, "chown #{$user}:#{$user} /home/#{$user}/.inputrc"
  end
  verify do
    file_contains "/home/#{$user}/.inputrc", 'set completion-ignore-case on'
  end
end

package :gem_rc do
  description 'turn off ri and rdoc'
  file "/home/#{$user}/.gemrc", :content => File.read('personalisations/.gemrc') do
    post :install, "chown #{$user}:#{$user} /home/#{$user}/.gemrc"
  end
  verify do
    file_contains "/home/#{$user}/.gemrc", '--no-rdoc --no-ri'
  end
end

#Remove requires lines for bits you don't need
policy :pentest, :roles => :test do
  requires :basics
  requires :metasploit_dependencies
  requires :nmap
  requires :ruby_gems
  requires :metasploit
  requires :java
  requires :testing_scripts
  requires :arachni
  requires :nikto
  requires :wireshark
  requires :network_clients
  requires :input_rc
  requires :gem_rc
  requires :seclists
  requires :testing_tools
  requires :network_tools
  requires :docker
  requires :zap
  requires :beef
  requires :apache_directory_studio
  requires :hoppy
end

#This is where you specify the machine to deploy to
#Currently this is set-up for a local machine
deployment do
  delivery :local 
  source do
    prefix    '/usr/local'
    archives  '/usr/local/sources'
    builds    '/usr/local/build'
  end
end