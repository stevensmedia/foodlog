Dir::glob(__DIR__('*.rb')).each { |x| require x  if x != 'init.rb' }
