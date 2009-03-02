require 'test_helper'

class ProcessRegistriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:process_registries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create process_registry" do
    assert_difference('ProcessRegistry.count') do
      post :create, :process_registry => { }
    end

    assert_redirected_to process_registry_path(assigns(:process_registry))
  end

  test "should show process_registry" do
    get :show, :id => process_registries(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => process_registries(:one).id
    assert_response :success
  end

  test "should update process_registry" do
    put :update, :id => process_registries(:one).id, :process_registry => { }
    assert_redirected_to process_registry_path(assigns(:process_registry))
  end

  test "should destroy process_registry" do
    assert_difference('ProcessRegistry.count', -1) do
      delete :destroy, :id => process_registries(:one).id
    end

    assert_redirected_to process_registries_path
  end
end
