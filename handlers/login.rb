get "/oauth/connect" do
  session[:code] = Pocket.get_code(:redirect_uri => CALLBACK_URL)
  new_url = Pocket.authorize_url(:code => session[:code], :redirect_uri => CALLBACK_URL)
  redirect new_url
end

get "/oauth/callback" do
  result = Pocket.get_result(session[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = result['access_token']
  user = User.first_or_create(username: result['username'])
  user.access_token = result['access_token']
  user.save!
  session[:user_id] = user.id
  HarvestArticles.perform_async(user.id)
  redirect "/"
end
