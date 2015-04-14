class FoodController < Controller
	map '/food', :foodlog

	def index
		login_required

		@title = "Food"
		@foods = Food.order(:name)
	end

	def food_hash_from_request(request)
		hash = {
			:name => request[:name],
			:calories => BigDecimal(request[:calories]),
			:fat => BigDecimal(request[:fat]),
			:saturated_fat => BigDecimal(request[:saturated_fat]),
			:cholesterol => BigDecimal(request[:cholesterol]),
			:sodium => BigDecimal(request[:sodium]),
			:carbohydrates => BigDecimal(request[:carbohydrates]),
			:fiber => BigDecimal(request[:fiber]),
			:protein => BigDecimal(request[:protein]),
		}
		for label in [:id, :calories, :fat, :saturated_fat, :cholesterol, :sodium, :carbohydrates, :fiber, :protein]
			if hash[label] == ''
				hash[label] = BigDecimal('0')
			end
		end
		if hash[:name] == ''
			hash[:name] = "New Food"
		end
		return hash
	end

	def add
		login_required

		if request[:id]
			request[:id] = nil
			food = Food.create(food_hash_from_request(request))
			redirect route("/")
		end

		@food = Object.new
		for label in [:id, :calories, :fat, :saturated_fat, :cholesterol, :sodium, :carbohydrates, :fiber, :protein]
			@food.define_singleton_method(label) do
				BigDecimal('0')
			end
		end
		@food.define_singleton_method(:name) do
			"New Food"
		end

		@title = "Add Food"
		@action = route(:add)
		@submit = "Add Food"
		@delete = false
		render_view :edit
	end

	def edit(id)
		login_required

		@food = Food[id]

		if !@food
			return do404("Invalid food.")
		end

		if request[:id]
			if request[:delete]
				@food.delete
				redirect route("/")
			else
				@food.update(food_hash_from_request(request))
			end
		end

		@title = "Edit Food #{@food.name}"
		@action = route("edit/#{id}/")
		@submit = "Edit Food"
		@delete = true
	end
end
