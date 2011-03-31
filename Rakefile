# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :minitest
Hoe.plugin :git
Hoe.plugin :compiler

Hoe.spec 'pasteboard' do
  developer 'Eric Hodel', 'drbrain@segment7.net'

  rdoc_locations <<
    'docs.seattlerb.org:/data/www/docs.seattlerb.org/pasteboard/'

  self.readme_file = 'README.rdoc'
  self.extra_rdoc_files = %w[ext/pasteboard/pasteboard.c]
end

# vim: syntax=ruby
