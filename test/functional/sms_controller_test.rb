require 'test_helper'

class SmsControllerTest < ActionController::TestCase
  setup do
    @sms = sms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sms" do
    assert_difference('Sms.count') do
      post :create, sms: { content: @sms.content, globalid: @sms.globalid, isflash: @sms.isflash, localid: @sms.localid, ok: @sms.ok, phone: @sms.phone, pl: @sms.pl, sent: @sms.sent, status_id: @sms.status_id, subject: @sms.subject }
    end

    assert_redirected_to sms_path(assigns(:sms))
  end

  test "should show sms" do
    get :show, id: @sms
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sms
    assert_response :success
  end

  test "should update sms" do
    put :update, id: @sms, sms: { content: @sms.content, globalid: @sms.globalid, isflash: @sms.isflash, localid: @sms.localid, ok: @sms.ok, phone: @sms.phone, pl: @sms.pl, sent: @sms.sent, status_id: @sms.status_id, subject: @sms.subject }
    assert_redirected_to sms_path(assigns(:sms))
  end

  test "should destroy sms" do
    assert_difference('Sms.count', -1) do
      delete :destroy, id: @sms
    end

    assert_redirected_to sms_index_path
  end
end
