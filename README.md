# Laptop Setup Script

A script using [sprinkle](https://github.com/sprinkle-tool/sprinkle) to setup network/web app security testing tools.

There's a load of these scripts out there, mainly using shell scripting.  I prefer sprinkle as it's a bit more intelligent, so things like detecting that tools are already installed are more easily handled (there's nothing here you couldn't do with bash, but this seems neater)

Designed to work on Ubuntu either via sudo or as root.

First up you need sprinkle installed, which needs ruby so

[rvm](https://rvm.io/) is a good way to do that.  Then setup ruby 2.2 as the default and install sprinkle as a rubygem ```gem install sprinkle```

After that you should be able to run the script with

```sprinkle -v -s sprinkle-local.rb```

## TODO

At the moment all the tools install as a block.  A nicer idea might be to split them into roles (e.g. network testing, web testing)