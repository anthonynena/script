# Script to create resource files to run recon-ng for specific clients


require 'optparse'
require 'rubygems'

options = {}
optparse = OptionParser.new do |opts|
	#Help Option Contents
	opts.banner = "
Usage:
			
recon.rb -d domains.txt -c client -r resource.rc\n\n"
	
	#Define domain input list
	opts.separator ""
	opts.on( '-d', '--domains FILE', 'Client Domains File' ) do |d|
		options[:domainslist] = d
	end
 	
	#Defines workspace name
	options[:client] = "default"
	opts.on( '-c', '--client CLIENT', 'Workspace Name' ) do |c|
		options[:client] = c
	end
	
	#Defines output file name
	options[:resource] = "resource.rc"
	opts.on( '-r', '--resource OUTPUT', 'Resource File' ) do |r|
		options[:resource] = r
	end
	
	#Defines the help option
	opts.on( '-h', '--help', 'Display this screen' ) do
		puts opts
		exit
	end
end

#Help Menu
def help() 
	puts "
recon.rb -d domains.txt -c client -r resource.rc\n
    -d, --domains FILE               Client Domains File
    -c, --client CLIENT              Workspace Name
    -r, --resource OUTPUT            Resource File
    -h, --help                       Display this screen"
end

#If an invalid option is passed, then display help and exit, otherwise parse the options

begin
optparse.parse!
if options[:domainslist]==nil #If file arguement is not passed, then display help and exit
	help()
	exit
else
	domains2=options[:domainslist]
end
if options[:client]==nil #If no client name is specified
	puts "No client name specified.  Setting workspace to default"
else
	client2=options[:client]
end
if options[:resource]==nil #If no resource file is specified then use resource.rc
		puts "No resource file specified.  Ouputting to resource.rc"
else
	resource2=options[:resource]
end
rescue OptionParser::ParseError
	help() #If a bad arguement was passed
	exit
end

# Creates an array of the modules to run, remove/add to customize/update script
	
modules = ["use recon/hosts/gather/http/web/bing_domain",
"use recon/hosts/gather/http/web/google_site",
"use recon/hosts/gather/http/web/yahoo_site",
"use recon/hosts/gather/http/web/baidu_site",
"use recon/hosts/gather/http/web/netcraft",
"use recon/hosts/gather/dns/brute_hosts",
"use recon/hosts/gather/http/web/ssl_san",
"use recon/hosts/gather/http/web/vpnhunter"
]
outfile = File.open("#{resource2}", "w") # Creates resource file for writing
	outfile.puts "workspace #{client2}" # Sets workspace to client name
	domains = IO.readlines("#{domains2}") # Loops through domains and writes commands to resource files
	modules.each{|a| 
	outfile.puts a
	domains.each{|dom|
		outfile.puts "set domain #{dom}"
		outfile.puts "run"
		}
		}
	outfile.puts "use recon/hosts/gather/http/web/ip_neighbor"
	outfile.puts "run"
	outfile.puts "use recon/hosts/enum/dns/resolve"
	outfile.puts "run"
	outfile.puts "use reporting/csv"
	outfile.puts "set TABLES hosts"
	outfile.puts "run"
outfile.close
