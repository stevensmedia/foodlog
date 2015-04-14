Sequel.migration do
	up do
		create_table(:weights) do
			Date :date
			BigDecimal :weight, :size =>[12,4]
		
			index([:date], {:unique => true})
		end
	end

	down do
		drop_table(:weights)
	end
end
