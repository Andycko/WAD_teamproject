require 'sinatra'
require 'sinatra/activerecord'

set :bind, '0.0.0.0'

ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'wiki.db'
)

class User < ActiveRecord::Base
    validates :username, presence: true, uniqueness: true
    validates :password, presence: true
end

$myInfo = "Andrej Szalma"
@info = ""

#This variable is global because we use it to determine if the login pup-up is open or not - Andrej
$login = ""

def readFile(filename)
    info = ""
    file = File.open(filename)

    file.each do |line|
        info = info + line
    end

    file.close
    $myInfo = info
end

get "/" do
    info = "Hello there!"
 	readFile("name.txt")
	@info = info + " " + $myInfo
	erb :home
end

get "/about" do
    erb :about
end

get "/create" do
    erb :create
end

get "/edit" do
    erb :edit
end

put "/edit" do
    info = "#{params[:message]}"
    @info = info
    file = File.open("name.txt","w")
    file.puts @info
    file.close
    redirect "/"
end

post '/login' do 
    $credentials = [params[:username],params[:password]]
    @Users = User.where(:username => $credentials[0]).to_a.first
    if @Users
        if @Users.password == $credentials[1] 
            $login = "true"
            redirect "/"
        else 
            $credentials = ['','']
            $login = "false"
#            Redirects to the url prior the post
            redirect back
        end 
    else 
        $credentials = ['','']
        $login = "false"
#        Redirects to the url prior the post
        redirect back
    end
end 

post '/no_login' do
#    This post was introduced for the login pop-up "X" (closing) button
#    The button had to be a form so we can change the state of the $login var, can't be done with a lin
    $login = ""
#    Redirects to the url prior the post
    redirect back
end

get '/logout' do
    $login = ""
    $credentials = ['','']
    redirect "/"
end


not_found do
    status 404
    redirect '/'
end
