require File.dirname(__FILE__) + '/../lib/search_model'
require File.dirname(__FILE__) + '/test_helper'

class PostSearch < SearchModel
  search_attributes :keyword, :author, :date
end

class SearchModelTest < ActiveSupport::TestCase

  def setup
    setup_db
  end
  
  def teardown
    teardown_db
  end
  
  def search_scope(params)
    PostSearch.new(params).results.proxy_options
  end
  
  %w(keyword author date).each do |attribute|
    test "should initialize #{attribute} using mass assignment" do
      search = PostSearch.new(attribute => 'foo')
      assert_equal 'foo', search.send(attribute)
    end      
  end
  
  test 'should ignore blank string search parameters' do
    assert search_scope(:keyword => '').empty?  
  end
  
  test 'should ignore empty array search parameters' do
    assert search_scope(:keyword => []).empty?
  end

  test 'should ignore empty hash search parameters' do
    assert search_scope(:keyword => {}).empty?
  end

  test 'should ignore array with blank values search parameters' do
    assert search_scope(:keyword => [''])  
  end

  test 'should ignore hash with blank values search parameters' do
    assert search_scope(
      :keyword => {:first => '', :second => ''}
    ).empty?
  end

  test 'should ignore HashWithIndifferentAccess with blank values search parameters' do
    assert search_scope(
      HashWithIndifferentAccess.new(:keyword => {:first => '', :second => ''})
    ).empty?  
  end  
  
  test 'should combine search parameters with non empty values as scopes' do
    assert_equal Post.by_keyword('Test').by_author('Me').proxy_options,
      search_scope(:keyword => 'Test', :author => 'Me')
  end  
 
end
