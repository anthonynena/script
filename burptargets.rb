#File to populate multiple targets into burp.


require 'rubygems'
require 'mechanize'
require 'timeout'
require 'optparse'

getPage = Mechanize.new #create the object
proxysite=nil
proxyport=nil
getPage.agent.ssl_version = 'SSLv3' #Just default to SSLv3 because most sites won't accept tlsv1
getPage.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE #ignore/accept all certificates
#getPage.follow_meta_refresh = true  #only uncomment if you want to follow meta refresh "redirects" - note:very time consuming

options = {}
optparse = OptionParser.new do|opts|
	#Help Option Contents
	opts.banner = "	
Usage:
			
burpTargets.rb -i websites.txt\n\n"
	
	#Define input 
	options[:inputfile] = nil
	opts.on( '-i', '--inputfile FILE', '(required) Format: http(s)://site.com' ) do|file1|
		options[:inputfile] = file1
	end
 
	#Defines the help option
	opts.on( '-h', '--help', 'Display this screen' ) do
		puts opts
		exit
	end
	
	#Defines proxy address - if not specific the default of 127.0.0.1 is used
	options[:proxyaddr] = nil
	opts.on( '-a', '--address PROXY_ADDRESS', 'Default is 127.0.0.1' ) do|address|
		options[:proxyaddr] = address
	end
	
	#Defines proxy port - if not defined the default of 8080 is used
	options[:proxypt] = nil
	opts.on( '-p', '--port PROXY_PORT', 'Default is 8080' ) do|port|
		options[:proxypt] = port
	end
	
end

#Help Menu
def help() 
	puts "\nUsage:
			
burpTargets.rb -i websites.txt\n
    -i, --inputfile FILE             (required) Format: http(s)://site.com
    -h, --help                       Display this screen
    -a, --address PROXY_ADDRESS      Default is 127.0.0.1
    -p, --port PROXY_PORT            Default is 8080"
end
 
#If an invalid option is passed, then display help and exit, otherwise parse the options
begin
	optparse.parse!
	if options[:inputfile]==nil #If file arguement is not passed, then display help and exit
		help()
		exit
	end
	if options[:proxyaddr]==nil #If no address used then use 127.0.0.1
		proxysite='127.0.0.1'
	else
		proxysite=options[:proxyaddr]
		puts "\nA proxy address of #{proxysite} is being used.\n"
	end
	if options[:proxypt]==nil #If no port is specified then use 8080
		proxyport=8080
	else
		proxyport=options[:proxypt]
		puts "\nA proxy port of #{proxyport} is being used.\n"
	end
rescue OptionParser::ParseError
	help() #If a bad arguement was passed
	exit
end

#everything above is just to get the options from command line (must be a more concise way) - The below code actually connects to the website

getPage.set_proxy("#{proxysite}", proxyport) #set the proxy

begin
File.open(options[:inputfile]).each do |line| #read the file of websites
	cleanSite=line.chomp()
	puts "Accessing #{line}"
	
	begin
		timeout (15) do #wrap the entire GET request around a time out rescue to prevent crashing if a website timeouts after 15 seconds
			getPage.get(line) #perform a GET on the page
			getPage.history.pop() #delete any previous history on a GET that occurred for a page already
		end
		rescue Timeout::Error #catch the time out error
			puts "Timeout Error at #{line}\n"
		rescue Mechanize::ResponseCodeError => exception #catch any other HTTP errors
			puts "#{exception.response_code} Error: #{line}\n"
	end
end
rescue Exception => e
  puts "Error Could Not Connect - Is the proxy running? #{e}"
end
