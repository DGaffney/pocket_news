get "/:hashid" do
  @user = User.find(User.id_from_hashid(params[:hashid]))
  @viewing_other_person = true
  redirect '/oauth/connect' if @user.nil?
  erb :"index"
end

get '/' do
  @user = User.find(session[:user_id])
  @viewing_other_person = false
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