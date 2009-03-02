require 'test_helper'

class OsProcessesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:os_processes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create os_process" do
    assert_difference('OsProcess.count') do
      post :create, :os_process => { }
    end

    assert_redirected_to os_process_path(assigns(:os_process))
  end

  test "should show os_process" do
    get :show, :id => os_processes(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => os_processes(:one).id
    assert_response :success
  end

  test "should update os_process" do
    put :update, :id => os_processes(:one).id, :os_process => { }
    assert_redirected_to os_process_path(assigns(:os_process))
  end

  test "should destroy os_process" do
    assert_difference('OsProcess.count', -1) do
      delete :destroy, :id => os_processes(:one).id
    end

    assert_redirected_to os_processes_path
  end
end
