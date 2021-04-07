# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :gemspec  # `gem install hoe-gemspec`
Hoe.plugin :git      # `gem install hoe-git`
Hoe.plugin :minitest # `gem install hoe-minitest`

Hoe.spec 'minitest-rg' do
  developer 'Mike Moore', 'mike@blowmage.com'

  self.summary     = 'Red/Green for MiniTest'
  self.description = 'Colored red/green output for Minitest'
  self.urls        = ['http://blowmage.com/minitest-rg']
  self.license       "MIT"

  self.readme_file       = 'README.rdoc'
  self.history_file      = 'CHANGELOG.rdoc'

  dependency 'minitest',  '~> 5.0'
end

# vim: syntax=ruby
