get '/' do
  if params[:user_id]
    @user = User.find(params[:user_id])
  elsif session[:user_id]
    @user = User.find(session[:user_id])
  end
  redirect '/oauth/connect' if @user.nil?
  erb :"index"
end

get '/stats/:user_id/:name.json' do
  user = User.find(params[:user_id])
  Stats.new.retrieve(user.username, params[:name]).to_json
end

get '/sign_out' do
  session.delete(:session_id)
  erb :"logout"
end