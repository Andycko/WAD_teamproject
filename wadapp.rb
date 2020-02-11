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

$myInfo = "" #
@info = ""


#This variable is global because we use it to determine if the login pop-up is open or not - Andrej
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
    @wordcount = @info.split.size
    @charactercount = @info.size #For now counts all possible characters(including html tags), but this is a bit irrelevant atm.
	erb :home
end

helpers do
    def protected!
	  	if authorized?
            return
        end
        redirect '/denied'
    end
    def authorized? 
	  	if $credentials != nil
	  	 	@Userz = User.where(:username => $credentials[0]).to_a.first
	  	 	if @Userz
	  	 	 	if @Userz.edit == true
	  	 	 	 	return true
	  	 	 	else
	  	 	 	 	return false
	  	 	 	end
	  	 	else
	  	 	 	return false
	  	 	end
	  	end 
    end
end

#List of links

get "/about" do
    erb :about
end

get "/create" do
    erb :create
end

get "/edit" do
    erb :edit
end

get "/createaccount" do
    erb :createaccount
end

get '/alreadytaken' do
    erb :alreadytaken
end

get '/noaccount' do
    erb :noaccount 
end

get '/denied' do
    erb :denied
end

put "/edit" do
    protected!
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
            time = Time.now
            var = time.to_s + "\t" + "Login:\t" + $credentials[0]
            File.open("log_of_users.txt","a") do |line|
                line.puts "\r" + var
            end
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
#    The button had to be a form so we can change the state of the $login var, can't be done with a link
    $login = ""
#    Redirects to the url prior the post
    redirect back
end

get '/logout' do
    $login = ""
    time = Time.now
    var = time.to_s + "\t" + "Logout:\t" + $credentials[0]
    File.open("log_of_users.txt","a") do |line|
        line.puts "\r" + var
    end
    $credentials = ['','']
    redirect "/"
end

not_found do
    status 404
    redirect '/'
end


get '/user/:uzer' do
    #protected!
    @Userz = User.where(:username => params[:uzer]).to_a.first
    if @Userz != nil
        erb :profile 
    else
        redirect '/denied'
    end
end

put '/user/:uzer' do
    n = User.where(:username => params[:uzer]).to_a.first
    n.edit = params[:edit] ? 1 : 0
    n.save 
    redirect '/' 
end

get '/admincontrols' do
    protected!
    @list2 = User.all.sort_by { |u| [u.id] }
    erb :admincontrols
end

get '/user/delete/:uzer' do   
    protected!
    n = User.where(:username => params[:uzer]).to_a.first
        if n.username == "Admin" 
            erb :denied
        else
            n.destroy    
            @list2 = User.all.sort_by { |u| [u.id] } 
        		erb :admincontrols
        end
end

#Administrator Login is Provided, and Admin features are locked due to security reasons.
post '/createaccount' do  n = User.new
    n.username = params[:username] 
    n.password = params[:password]
    booltest = 1
    @list2 = User.all.sort_by { |u| [u.id] } 
    @list2.each do |liste|
        if liste.username == n.username
            booltest = 0
        end
    end
    if booltest == 1
        n.save
        redirect '/'
    else
        redirect '/alreadytaken'
    end
    ##Create a Already Exists Output - DISPLAYING AN ERROR MESSAGE IS A WORK IN PROGRESS
    ##And display error message
end

post "/archive" do
    protected!
    IO.copy_stream('name.txt', 'archive.txt')
    redirect "/"
end

post "/restore" do
    protected!
    IO.copy_stream('archive.txt', 'name.txt')
    redirect "/"
end

post "/default" do
    protected!
    File.open("name.txt") do |line|
        line.puts "Andrew"
    end
    redirect "/"
end
