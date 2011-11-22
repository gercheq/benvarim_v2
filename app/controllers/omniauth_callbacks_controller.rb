class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    auth = env["omniauth.auth"]
    fb_user_id = auth['uid']
    fb_connect = FbConnect.find_by_fb_user_id(fb_user_id)
    if !fb_connect
      #new fb connect, save it!
      fb_connect = FbConnect.new({
        :fb_user_id => fb_user_id,
        :auth => auth
      })
    end
    @user = User.find_or_create_by_fb_connect fb_connect
    if @user && @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      @user.remember_me = true
      sign_in_and_redirect @user, :event => :authentication
      if "popup" == params[:state]
        #instead of redirect, redirect opener
        @redirect_url = after_sign_up_path
      else
        # sign_in_and_redirect @user, :event => :authentication
        @redirect_url = after_sign_in_path_for(:user)
      end
    else
      session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end