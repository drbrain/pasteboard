# -*- ruby -*-

task :default => :compile

require 'rubygems'
require 'hoe'

Hoe.plugin :minitest
Hoe.plugin :git
Hoe.plugin :compiler

Hoe.spec 'pasteboard' do
  developer 'Eric Hodel', 'drbrain@segment7.net'

  rdoc_locations << 'docs.seattlerb.org:/data/www/docs.seattlerb.org/pasteboard/'

  self.clean_globs = %w[
    lib/pasteboard/pasteboard.bundle
  ]

  self.spec_extras[:extensions] = %w[ext/pasteboard/extconf.rb]
  self.readme_file = 'README.rdoc'
end

# vim: syntax=ruby
