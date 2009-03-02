require 'test_helper'

class UrlStatisticsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:url_statistics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create url_statistic" do
    assert_difference('UrlStatistic.count') do
      post :create, :url_statistic => { }
    end

    assert_redirected_to url_statistic_path(assigns(:url_statistic))
  end

  test "should show url_statistic" do
    get :show, :id => url_statistics(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => url_statistics(:one).id
    assert_response :success
  end

  test "should update url_statistic" do
    put :update, :id => url_statistics(:one).id, :url_statistic => { }
    assert_redirected_to url_statistic_path(assigns(:url_statistic))
  end

  test "should destroy url_statistic" do
    assert_difference('UrlStatistic.count', -1) do
      delete :destroy, :id => url_statistics(:one).id
    end

    assert_redirected_to url_statistics_path
  end
end
