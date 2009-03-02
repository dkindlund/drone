require 'test_helper'

class FileContentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:file_contents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create file_content" do
    assert_difference('FileContent.count') do
      post :create, :file_content => { }
    end

    assert_redirected_to file_content_path(assigns(:file_content))
  end

  test "should show file_content" do
    get :show, :id => file_contents(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => file_contents(:one).id
    assert_response :success
  end

  test "should update file_content" do
    put :update, :id => file_contents(:one).id, :file_content => { }
    assert_redirected_to file_content_path(assigns(:file_content))
  end

  test "should destroy file_content" do
    assert_difference('FileContent.count', -1) do
      delete :destroy, :id => file_contents(:one).id
    end

    assert_redirected_to file_contents_path
  end
end
