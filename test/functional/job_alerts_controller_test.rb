require 'test_helper'

class JobAlertsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:job_alerts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create job_alert" do
    assert_difference('JobAlert.count') do
      post :create, :job_alert => { }
    end

    assert_redirected_to job_alert_path(assigns(:job_alert))
  end

  test "should show job_alert" do
    get :show, :id => job_alerts(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => job_alerts(:one).id
    assert_response :success
  end

  test "should update job_alert" do
    put :update, :id => job_alerts(:one).id, :job_alert => { }
    assert_redirected_to job_alert_path(assigns(:job_alert))
  end

  test "should destroy job_alert" do
    assert_difference('JobAlert.count', -1) do
      delete :destroy, :id => job_alerts(:one).id
    end

    assert_redirected_to job_alerts_path
  end
end
