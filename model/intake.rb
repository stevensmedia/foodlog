class Intake < Sequel::Model
	set_schema do
		primary_key :id

		Date :date
		BigDecimal :amount, :size =>[12,4]

		foreign_key :food_id
	end

	many_to_one :food

	def calories
		self.amount * self.food.calories
	end

	def self.daily_calories(date = Date.today)
		Intake.filter({:date => date}).reduce(BigDecimal("0")) do |sum, intake|
			sum + intake.calories
		end
	end
end
