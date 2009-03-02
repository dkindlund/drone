require 'test_helper'

class ClientStatusesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:client_statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create client_status" do
    assert_difference('ClientStatus.count') do
      post :create, :client_status => { }
    end

    assert_redirected_to client_status_path(assigns(:client_status))
  end

  test "should show client_status" do
    get :show, :id => client_statuses(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => client_statuses(:one).id
    assert_response :success
  end

  test "should update client_status" do
    put :update, :id => client_statuses(:one).id, :client_status => { }
    assert_redirected_to client_status_path(assigns(:client_status))
  end

  test "should destroy client_status" do
    assert_difference('ClientStatus.count', -1) do
      delete :destroy, :id => client_statuses(:one).id
    end

    assert_redirected_to client_statuses_path
  end
end
