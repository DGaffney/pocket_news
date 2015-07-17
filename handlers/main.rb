get '/' do
  @user = User.find(session[:user_id]) if session[:user_id]
  redirect '/oauth/connect' if @user.nil?
  erb :"index"
end

get '/stats/:user_id/:name.json' do
  user = User.find(params[:user_id])
  Stats.new.retrieve(user.username, params[:name]).to_json
end

get '/sign_out' do
  session.delete(:session_id)
  redirect "/"
end