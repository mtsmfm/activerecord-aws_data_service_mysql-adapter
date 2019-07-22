require 'bundler/setup'

require 'active_record'

$LOAD_PATH << File.join(__dir__, 'lib')

ActiveRecord::Base.establish_connection
p ActiveRecord::Base.connection.execute('SELECT 1')
