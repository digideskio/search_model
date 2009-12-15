require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

$stdout = StringIO.new

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :posts do |t|
      t.string :title, :body, :author
      t.timestamps
    end
  end  
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end  
end

setup_db
class Post < ActiveRecord::Base
  named_scope :by_keyword, lambda { |value| 
    {
    :conditions => ['(title like ? OR body like ?)', "%#{value}%", "%#{value}%"]  
    }
  }
  named_scope :by_author, lambda { |value|
    {
      :conditions => ['author like ?', "%#{value}%"]      
    }
  }
  named_scope :by_date, lambda { |value|
    {
      :conditions => ['created_at = ?', value]    
    }
  }
end
teardown_db
