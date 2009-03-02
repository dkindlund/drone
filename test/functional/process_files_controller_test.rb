require 'test_helper'

class ProcessFilesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:process_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create process_file" do
    assert_difference('ProcessFile.count') do
      post :create, :process_file => { }
    end

    assert_redirected_to process_file_path(assigns(:process_file))
  end

  test "should show process_file" do
    get :show, :id => process_files(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => process_files(:one).id
    assert_response :success
  end

  test "should update process_file" do
    put :update, :id => process_files(:one).id, :process_file => { }
    assert_redirected_to process_file_path(assigns(:process_file))
  end

  test "should destroy process_file" do
    assert_difference('ProcessFile.count', -1) do
      delete :destroy, :id => process_files(:one).id
    end

    assert_redirected_to process_files_path
  end
end
