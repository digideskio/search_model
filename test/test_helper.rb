require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

$stdout = StringIO.new

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    #create tables here
  end  
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end  
end

setup_db
#define models here
teardown_db
