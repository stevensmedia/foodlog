class IntakeController < DateController
	map '/intake', :foodlog

	def allow_add
		return Food.count > 0
	end

	def foods_list(selected = nil)
		retval = ''
		for food in Food.order(:name).all
			retval += "
			<option value=\"#{food.id}\" #{selected == food ? 'selected="true"' : ''}>#{::CGI::escapeHTML(food.name)}</option>
			"
		end
		return retval
	end

	def intake_hash_from_request(request)
		hash = {
			:food_id => request[:food_id],
			:date => request[:date],
			:amount => BigDecimal(request[:amount]),
		}
		for label in [:food_id, :amount]
			if hash[label] == ''
				hash[label] = BigDecimal('0')
			end
		end
		return hash
	end

	def index(*args)
		return default_index(Intake, :day, *args) do |*args|
			@title = "Intake for #{@date}"
			@intakes = Intake.filter({:date => @date})
			@total = Intake.daily_calories(@date)
			@allow_add = allow_add
		end
	end

	def complete_add
		request[:date] = @date
		request[:id] = nil
		intake = Intake.create(intake_hash_from_request(request))
		redirect date_route(@date)
	end

	def do_add(*args)
		if !allow_add
			return redirect FoodController::route()
		end

		default_do_add(:edit, *args) do |*args|
			@intake = Object.new
			for label in [:id, :food_id]
				@intake.define_singleton_method(label) do
					BigDecimal('0')
				end
			end
			@intake.define_singleton_method(:amount) do
				BigDecimal('1')
			end
			singleton_date = @date
			@intake.define_singleton_method(:date) do
				singleton_date
			end

			@title = "Add intake for #{@date}"
			@action = date_route(@date, 'add/')
			@submit = "Add"
			@delete = false
			@foods = foods_list
		end
	end

	def complete_edit
		@intake.update(intake_hash_from_request(request))
	end

	def do_edit(*args)
		default_do_edit(Intake, :edit, *args) do |*args|
			@title = "Edit intake for #{@intake.date}"
			@action = route("edit/#{@intake.id}/")
			@submit = "Edit Intake"
			@delete = true
			@foods = foods_list(@intake.food)
		end
	end
end
