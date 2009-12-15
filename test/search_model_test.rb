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

  test 'should correctly overwrite attributes on mass assignment' do
    search = PostSearch.new
    search.attributes = {:keyword => 'foo'}
    assert_equal 'foo', search.keyword
    search.attributes = {:author => 'me'}
    assert_equal 'me', search.author
    assert_equal 'foo', search.keyword
  end

  test 'should strip spaces leading and trailing spaces from attributes' do
    search = PostSearch.new(:keyword => ' foo ')
    assert_equal 'foo', search.keyword
    search.author = ' me '
    assert_equal 'me', search.author
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
  
  test 'should be blank when no parameters are entered' do
    assert PostSearch.new.blank?  
  end
  
  test 'should not be blank when at least one parameter is entered' do
    assert !PostSearch.new(:keyword => 'Test').blank?
  end
 
end
