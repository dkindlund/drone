require 'test_helper'

class UrlStatusesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:url_statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create url_status" do
    assert_difference('UrlStatus.count') do
      post :create, :url_status => { }
    end

    assert_redirected_to url_status_path(assigns(:url_status))
  end

  test "should show url_status" do
    get :show, :id => url_statuses(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => url_statuses(:one).id
    assert_response :success
  end

  test "should update url_status" do
    put :update, :id => url_statuses(:one).id, :url_status => { }
    assert_redirected_to url_status_path(assigns(:url_status))
  end

  test "should destroy url_status" do
    assert_difference('UrlStatus.count', -1) do
      delete :destroy, :id => url_statuses(:one).id
    end

    assert_redirected_to url_statuses_path
  end
end
