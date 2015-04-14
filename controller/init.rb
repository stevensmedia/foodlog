class Controller < Ramaze::Controller
	map nil, :foodlog

	app.location = FoodLog.options.location

	layout :default
	helper :xhtml
	helper :auth
	engine :Etanni

	trait :auth_table => (lambda do
		{FoodLog.options.admin.username => FoodLog.options.admin.password}
	end)

	def do404(message = "Not Found.")
		response.status = 404
		@title = "Not Found."
		render_file Ramaze.options.views[0] + "/404.xhtml", {:message => message}
	end

	def self.action_missing(path)
		return if path == "/do404"
		try_resolve("/do404")
	end
end

class DateController < Controller
	map nil, :foodlog

	def self.pad2(i)
		s = i.to_s
		if s.length == 1
			s = "0#{s}"
		end
		return s
	end

	def validate_date(args, route = nil)
		if args.size == 0
			year = Date.today.year.to_s
			month = Date.today.month.to_s
			day = Date.today.day.to_s
		elsif args.size >= 3
			year = args[0].to_i.to_s
			month = pad2(args[1].to_i)
			day = pad2(args[2].to_i)

			if year != args[0] ||
			   month != args[1] ||
			   day != args[2]
				redirect date_route(@date, route)
			end
		else
			return do404("Invalid date. #{__LINE__}")
		end

		begin
			@date = Date.new(year.to_i, month.to_i, day.to_i)
		rescue ArgumentError => e
			return do404("Invalid date. #{__LINE__}")
		end

		if @date.year == 0
			return do404("Invalid date. #{__LINE__}")
		end

		return nil
	end

	def self.date_route(date, route = nil)
		return r("/#{date.year}/#{pad2(date.month)}/#{pad2(date.day)}/#{route}")
	end

	def default_index(field_class, view, *args)
		login_required
		@from_index = true

		if args.size == 4 && args[3] == 'add'
			return do_add(*args)
		elsif !field_class.primary_key && args.size == 4 && args[3] == 'edit'
			return do_edit(*args)
		elsif field_class.primary_key && args.size == 2 && args[0] == 'edit'
			return do_edit(*args)
		elsif ![0,3].include?(args.size)
			return do404("Invalid date. #{__LINE__}")
		end

		invalid = validate_date(args)
		return invalid if invalid

		@previous_route = date_route(@date - 1)
		@next_route = (@date == Date.today) ? nil : date_route(@date + 1)
		@add_route = date_route(@date, 'add/')

		yield(*args)

		render_view view
	end

	def default_do_add(view, *args)
		return do404 if !@from_index

		invalid = validate_date(args, 'add/')
		return invalid if invalid

		if request[:date]
			return complete_add
		end

		yield(*args)

		render_view view
	end

	def default_do_edit(field_class, view, *args)
		return do404 if !@from_index

	 	class_name = field_class.name.downcase
		instance_var_name = '@' + class_name

		if !field_class.primary_key && args.size == 4 && args[3] == 'edit'
			validate_date(args, 'edit/')
			instance_variable_set(instance_var_name,
			                      field_class.filter(:date => @date).first)
		elsif field_class.primary_key && args.size == 2
			id = args[1].to_i
			instance_variable_set(instance_var_name, field_class[id])
		else
			return do404("Invalid #{class_name}. #{__LINE__}")
		end

		instance_var = instance_variable_get(instance_var_name)

		if !instance_var
			return do404("Invalid #{class_name}. #{__LINE__}")
		end

		if request[:date]
			rt = date_route(instance_var.date || Date.today)
			if request[:delete]
				if field_class.primary_key
					instance_var.delete
				else
					field_class.filter(:date => @date).delete
				end
			else
				yield complete_edit
			end
			redirect rt
		end

		yield(*args)

		render_view view
	end
end

Dir::glob(__DIR__('*')).each { |x| require x  if x != 'init.rb' }
