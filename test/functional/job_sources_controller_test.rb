require 'test_helper'

class JobSourcesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:job_sources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create job_source" do
    assert_difference('JobSource.count') do
      post :create, :job_source => { }
    end

    assert_redirected_to job_source_path(assigns(:job_source))
  end

  test "should show job_source" do
    get :show, :id => job_sources(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => job_sources(:one).id
    assert_response :success
  end

  test "should update job_source" do
    put :update, :id => job_sources(:one).id, :job_source => { }
    assert_redirected_to job_source_path(assigns(:job_source))
  end

  test "should destroy job_source" do
    assert_difference('JobSource.count', -1) do
      delete :destroy, :id => job_sources(:one).id
    end

    assert_redirected_to job_sources_path
  end
end
