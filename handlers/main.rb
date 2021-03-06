require 'open-uri'
require 'json'
get '/weather' do
  return open("http://api.openweathermap.org/data/2.5/weather?lat=#{params[:lat]}&lon=#{params[:lon]}&appid=b095721129e2ecf359187e5853362f79&units=imperial").read
end

get '/' do
  @user = User.find(id: session[:user_id]) rescue nil
  @viewing_other_person = false
  redirect '/oauth/connect' if @user.nil?
  erb :"index"
end

get "/:hashid" do
if params[:hashid] == "weather"
  return open("http://api.openweathermap.org/data/2.5/weather?lat=#{params[:lat]}&lon=#{params[:lon]}&appid=b095721129e2ecf359187e5853362f79&units=imperial").read
else
  @user = User.find(id: User.id_from_hashid(params[:hashid])) rescue nil
  @viewing_other_person = true
  redirect '/oauth/connect' if @user.nil?
  erb :"index"
end
end

get '/stats/:user_id/:name.json' do
  user = User.find(id: params[:user_id]) rescue nil
  Stats.new.retrieve(user.username, params[:name]).to_json
end

get '/sign_out' do
  session.delete(:session_id)
  erb :"logout"
end

get '/weather' do
  return open("http://api.openweathermap.org/data/2.5/weather?lat=#{params[:lat]}&lon=#{params[:lon]}&appid=b095721129e2ecf359187e5853362f79&units=imperial").read
end
