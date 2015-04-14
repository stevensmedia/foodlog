module FoodLog
	include Ramaze::Optioned
	options.dsl do
		sub :admin do
			o "Username", :username, 'neil'
			o "Password", :password, Digest::SHA1.hexdigest('xxxxxx')
		end
		o "Location", :location, '/foodlog'
	end
end
