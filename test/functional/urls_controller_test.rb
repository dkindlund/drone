require 'test_helper'

class UrlsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:urls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create url" do
    assert_difference('Url.count') do
      post :create, :url => { }
    end

    assert_redirected_to url_path(assigns(:url))
  end

  test "should show url" do
    get :show, :id => urls(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => urls(:one).id
    assert_response :success
  end

  test "should update url" do
    put :update, :id => urls(:one).id, :url => { }
    assert_redirected_to url_path(assigns(:url))
  end

  test "should destroy url" do
    assert_difference('Url.count', -1) do
      delete :destroy, :id => urls(:one).id
    end

    assert_redirected_to urls_path
  end
end
