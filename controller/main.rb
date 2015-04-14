class MainController < Controller
	map '/', :foodlog

	def index
		@title = "Food Log"
	end

	def overview
		login_required

		@days = {}
		@weights = []
		@calorie_counts = []
		@day_labels = []
		weights = Weight.order(:date)
		count = weights.count > 0 ? Date.today - weights.first.date + 1 : 0
		for i in 0..count - 1
			d = Date.today - i
			it = Intake.daily_calories(d)
			wt = Weight.display_for_date(d)
			@days[d] = {}
			@days[d][:intake] = it
			@days[d][:weight] = wt
			@weights.push(wt.to_f)
			@calorie_counts.push(it.to_f)
			@day_labels.push(i % 7 == 0 ?  d.to_s : '')
		end

		@weights.reverse!
		@calorie_counts.reverse!
		@day_labels.reverse!

		@baseline = []
		first = weights.first.weight
		for i in 0..count - 1
			@baseline.push((first - 0.4 * i).to_f)
		end

		@title = "Overview of Progress"
	end
end
