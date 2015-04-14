DB = Sequel.mysql2(:host => '127.0.0.1',
                   :port => 3306,
                   :username => 'foodlog',
                   :password => 'xxxxxxxx',
                   :database => 'foodlog',
                   :encoding => 'utf8',
                  )
