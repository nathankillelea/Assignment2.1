# sources:
# https://github.com/ruby-grape/grape/issues/884

ENV['RACK_ENV'] = 'test'

require 'test/unit'
require 'rack/test'
require './graph/graph.rb'
require './graph/actor_node.rb'
require './graph/movie_node.rb'
require './graph/adjacent_node.rb'
require './api'
require 'active_support/core_ext/enumerable.rb'

class APITest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    API
  end

  def test_get_person
    get '/actors/Robert_Redford'
    assert last_response.body.include?("Robert Redford")
    assert_equal last_response.status, 200
  end

  def test_get_actor_by_name_and_age
    get '/actors?name=John&age=65'
    assert last_response.body.include?("John Goodman")
    assert last_response.body.include?("65")
    assert_equal last_response.status, 200
  end

  def test_get_movie
    get '/movies/Brubaker'
    assert last_response.body.include?("Brubaker")
    assert_equal last_response.status, 200
  end

  def test_get_movie_by_name_and_year
    get '/movies?name=The&year=1994'
    assert last_response.body.include?("The Shawshank Redemption")
    assert last_response.body.include?("The Puppet Masters")
    assert_equal last_response.status, 200
  end

  def test_update_actor
    params = {
        'age' => 20
    }

    env_request_headers = {
        'CONTENT_TYPE' => 'application/json'
    }

    put '/actors/Vince_Vaughn', params.to_json, env_request_headers
    assert_equal last_response.status, 200
    get '/actors/Vince_Vaughn'
    assert_equal last_response.status, 200
    assert last_response.body.include?("20")
  end

  def test_put_nonexistant_actor
    params = {
        'name' => 'Eggman Jones',
        'age' => 25,
        'total_grossing_value' => 42069
    }

    env_request_headers = {
        'CONTENT_TYPE' => 'application/json'
    }

    put '/actors/Eggman_Jones', params.to_json, env_request_headers
    assert_equal last_response.status, 201
    get '/actors/Eggman_Jones'
    assert_equal last_response.status, 200
    assert last_response.body.include?("Eggman Jones")
    assert last_response.body.include?("25")
    assert last_response.body.include?("42069")
  end

  def test_update_movie
    params = {
        'year' => 2020
    }

    env_request_headers = {
        'CONTENT_TYPE' => 'application/json'
    }

    put '/movies/The_Shawshank_Redemption', params.to_json, env_request_headers
    assert_equal last_response.status, 200
    get '/movies/The_Shawshank_Redemption'
    assert_equal last_response.status, 200
    assert last_response.body.include?("2020")
  end

  def test_put_nonexistant_movie
    params = {
        'name' => 'Sweet Dee',
        'year' => 2018,
        'box_office' => 575757
    }

    env_request_headers = {
        'CONTENT_TYPE' => 'application/json'
    }

    put '/movies/Sweet_Dee', params.to_json, env_request_headers
    assert_equal last_response.status, 201
    get '/movies/Sweet_Dee'
    assert_equal last_response.status, 200
    assert last_response.body.include?("Sweet Dee")
    assert last_response.body.include?("2018")
    assert last_response.body.include?("575757")
  end

  def test_post_actor
    params = {
        'name' => 'Johnny Bravo',
        'age' => 40
    }

    env_request_headers = {
        'HTTP_ACCEPT' => 'application/json',
        'CONTENT_TYPE' => 'application/json'
    }

    post '/actors', params.to_json, env_request_headers
    assert_equal last_response.status, 201
    get '/actors/Johnny_Bravo'
    assert last_response.body.include?("Johnny Bravo")
    assert_equal last_response.status, 200
  end

  def test_post_movie
    params = {
        'name' => 'Scary Spooky Skeleton',
        'box_office' => 222222,
        'year' => 1996
    }

    env_request_headers = {
        'HTTP_ACCEPT' => 'application/json',
        'CONTENT_TYPE' => 'application/json'
    }

    post '/movies', params.to_json, env_request_headers
    assert_equal last_response.status, 201
    get '/movies/Scary_Spooky_Skeleton'
    assert last_response.body.include?("Scary Spooky Skeleton")
    assert_equal last_response.status, 200
  end

  def test_delete_actor
    get '/actors/Morgan_Freeman'
    assert last_response.body.include?("Morgan Freeman")
    assert_equal last_response.status, 200
    delete '/actors/Morgan_Freeman'
    assert_equal last_response.status, 200
    get '/actors/Morgan_Freeman'
    assert_equal last_response.status, 400
  end

  def test_delete_movie
    get '/movies/Million_Dollar_Baby'
    assert last_response.body.include?("Million Dollar Baby")
    assert_equal last_response.status, 200
    delete '/movies/Million_Dollar_Baby'
    assert_equal last_response.status, 200
    get '/movies/Million_Dollar_Baby'
    assert_equal last_response.status, 400
  end
end