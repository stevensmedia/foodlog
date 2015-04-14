class Weight < Sequel::Model
	set_schema do
		Date :date
		BigDecimal :weight, :size =>[12,4]
	
		index([:date], {:unique => true})
	end

	def self.display_for_date(d)
		if w = Weight.filter{date <= d}.reverse(:date).limit(1).first
			return w.weight
		elsif w = Weight.filter{date > d}.order(:date).limit(1).first
			return w.weight
		else
			return BigDecimal('0.0')
		end
	end
end
