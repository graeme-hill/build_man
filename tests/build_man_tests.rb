require 'rubygems' if RUBY_VERSION < '1.9'
require 'fas_test'

class DataContextTests < FasTest::TestClass
  
  def class_setup
    @context = BuildMan::DataContext.new(":memory:")
    @context.migrate_database!
  end
  
  def test__get_projects__
    
  end
  
end