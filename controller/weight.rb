class WeightController < DateController
	map '/weight', :foodlog

	def allow_add
		Weight.filter(:date => @date).count == 0
	end

	def weight_hash_from_request(request)
		hash = {
			:date => request[:date],
			:weight => BigDecimal(request[:weight]),
		}
		for label in [:weight]
			if hash[label] == ''
				hash[label] = BigDecimal('0')
			end
		end
		return hash
	end

	def index(*args)
		return default_index(Weight, :day, *args) do |*args|
			@title = "Weight for #{@date}"
			d = @date
			@weights = Weight.filter{(date <= d) &
			                         (date >= d - 6)}.reverse(:date)
			@allow_add = allow_add
		end
	end

	def complete_add
		request[:date] = @date
		weight = Weight.create(weight_hash_from_request(request))
		redirect date_route(weight.date)
	end

	def do_add(*args)
		default_do_add(:edit, *args) do |*args|
			if !allow_add
				redirect date_route(@date)
			end

			@weight = Object.new
			singleton_date = @date
			for label in [:weight]
				@weight.define_singleton_method(label) do
					Weight.display_for_date(singleton_date)
				end
			end
			@weight.define_singleton_method(:date) do
				singleton_date
			end

			@title = "Add weight for #{@date}"
			@action = date_route(@date, 'add/')
			@submit = "Add"
			@delete = false
		end
	end

	def complete_edit
		Weight.filter(:date => @weight.date).set(:weight => BigDecimal(request[:weight]))
		@weight = Weight.filter(:date => @weight.date).first
	end

	def do_edit(*args)
		default_do_edit(Weight, :edit, *args) do |args|
			@title = "Edit weight for #{@date}"
			@action = date_route(@date, 'edit/')
			@submit = 'Edit Weight'
			@delete = true
		end
	end
end
