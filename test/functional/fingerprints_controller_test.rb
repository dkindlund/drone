require 'test_helper'

class FingerprintsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fingerprints)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fingerprint" do
    assert_difference('Fingerprint.count') do
      post :create, :fingerprint => { }
    end

    assert_redirected_to fingerprint_path(assigns(:fingerprint))
  end

  test "should show fingerprint" do
    get :show, :id => fingerprints(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => fingerprints(:one).id
    assert_response :success
  end

  test "should update fingerprint" do
    put :update, :id => fingerprints(:one).id, :fingerprint => { }
    assert_redirected_to fingerprint_path(assigns(:fingerprint))
  end

  test "should destroy fingerprint" do
    assert_difference('Fingerprint.count', -1) do
      delete :destroy, :id => fingerprints(:one).id
    end

    assert_redirected_to fingerprints_path
  end
end
