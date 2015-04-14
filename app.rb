require 'rubygems'
require 'ramaze'
require 'sequel'
require 'cgi'

require __DIR__('database')

Sequel::Model.plugin('schema')
Sequel::extension('migration')
Sequel::Migrator.apply(DB, __DIR__('model/migration/'))

# Make sure that Ramaze knows where you are
Ramaze.options.roots = [__DIR__]
Ramaze.options.publics = ['htdocs']

require __DIR__('options')

# Initialize controllers and models
require __DIR__('model/init')
require __DIR__('controller/init')
