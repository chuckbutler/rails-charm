%w(python-software-properties python g++ make).each do |pckg|
	package pckg do
		action :install
	end
end

execute 'add nodejs ppa' do
	command 'add-apt-repository -y ppa:chris-lea/node.js'
end

execute 'apt-get update' do
	command 'apt-get update'
end

package 'nodejs' do
	action :install
end