#This is a Sprinkle(https://github.com/sprinkle-tool/sprinkle) script for automating
#build of a security testing linux build (based on Ubuntu)
#Sources used 
#https://github.com/madmantm/ubuntu-pentest-tools/blob/master/ubuntu-pentest-tools.sh
#http://www.darkoperator.com/installing-metasploit-in-ubunt/
# Java From https://launchpad.net/~webupd8team/+archive/ubuntu/java

#this is a cut of a script for setting up a local laptop instead of over a network
#you need to get ruby working first so no packages for that
#Easiest way is likely to use rvm (http://rvm.io)
#To run this you need to use sudo or rvmsudo
#e.g. rvmsudo sprinkle -v -s sprinkle-local.rb

#At the moment I'm assuming this will be run with sudo (as opposed to running as root)
#This variable is used later for chown commands
$user = ENV['SUDO_USER']

package :build_essentials do
  description 'Build Essential Package'
  apt %w(build-essential), :sudo => true do 
    pre :install, 'apt-get update'
    pre :install, 'apt-get -y upgrade'
  end
end

package :wireshark do
  description 'Wireshark Packet Sniffer'
  apt %w(wireshark), :sudo => true
  verify do
    has_executable 'wireshark'
  end
end



package :nmap do
  description 'nmap'
  version '6.47'
  source "http://nmap.org/dist/nmap-#{version}.tar.bz2", :sudo => true
  requires :build_essentials
  verify do
    has_file '/usr/local/bin/nmap'
  end
end

package :general_dependencies do
  description 'useful packages for general use and installation'
  apt %w(git-core subversion vim), :sudo => true
end

package :network_clients do
  description 'network clients for various protocols (e.g. SMB, NFS)'
  apt %w(smbclient nfs-common rsh-client), :sudo => true
  verify do
    has
end

package :metasploit_dependencies do
  description 'Metasploit Dependencies'
  apt %w(libreadline-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev autoconf postgresql pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev vncviewer libyaml-dev), :sudo => true
end

package :rubygem_dependencies do
  description 'dependencies for ruby gems'
  apt %w(libxslt1-dev libxml2-dev), :sudo => true
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
  runner ['git clone https://github.com/rapid7/metasploit-framework.git', 'mv metasploit-framework/ /opt/'] do
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
  runner ['git clone https://github.com/raesene/TestingScripts.git', 'mv TestingScripts/ /opt/'] do
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
end

package :arachni do
  description 'arachni web app scanner'
  runner ['git clone https://github.com/Arachni/arachni.git', 'mv arachni/ /opt/'] do
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
end

package :nikto do 
  description 'nikto CGI scanner'
  runner ['git clone https://github.com/sullo/nikto.git', 'mv nikto/ /opt/'] do
    post :install, "chown -R #{$user}:#{$user} /opt/nikto"
  end
  verify do
    has_file '/opt/nikto/program/nikto.pl'
  end
  requires :nikto_dependencies
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

policy :pentest, :roles => :test do
  requires :metasploit_dependencies
  requires :nmap
  requires :ruby_gems
  requires :metasploit
  requires :java
  requires :testing_scripts
  requires :arachni
  requires :nikto
  requires :wireshark
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