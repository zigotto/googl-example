raise "No keys.yml was found" unless File.exist?(keys_file = "keys.yml")

$keys = YAML.load(File.read(keys_file))
$client_id, $client_secret = $keys['client_id'], $keys['client_secret']

configure do
  enable :sessions
  set :client, Googl::OAuth2.server($client_id, $client_secret, "http://gooogl.heroku.com/back")
end

before do
  @client = options.client
  @user = session[:user]
end

get "/" do
  erb :index
end

get "/auth/google" do
  redirect @client.authorize_url
end

get "/back" do
  code = params["code"]
  response = @client.request_access_token(code)
  session[:user] = @client.authorized?
  redirect "/"
end

get "/url/history" do
  if @client.authorized?
    @items = @client.history.items
    erb :history
  else
    redirect "/"
  end
end

get "/logout" do
  session.delete(:user)
  redirect "/"
end

post "/url/shorten" do
  long_url = params[:long_url]
  @url = Googl.shorten(long_url)
  erb :shorten
end
