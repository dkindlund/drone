require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:jobs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create job" do
    assert_difference('Job.count') do
      post :create, :job => { }
    end

    assert_redirected_to job_path(assigns(:job))
  end

  test "should show job" do
    get :show, :id => jobs(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => jobs(:one).id
    assert_response :success
  end

  test "should update job" do
    put :update, :id => jobs(:one).id, :job => { }
    assert_redirected_to job_path(assigns(:job))
  end

  test "should destroy job" do
    assert_difference('Job.count', -1) do
      delete :destroy, :id => jobs(:one).id
    end

    assert_redirected_to jobs_path
  end
end
