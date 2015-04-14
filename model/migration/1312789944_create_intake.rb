Sequel.migration do
	up do
		create_table(:intakes) do
			primary_key :id

			Date :date
			BigDecimal :amount, :size =>[12,4]

			foreign_key :food_id
		end
	end

	down do
		drop_table(:intakes)
	end
end
