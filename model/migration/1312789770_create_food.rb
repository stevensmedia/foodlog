Sequel.migration do
	up do
		create_table(:foods) do
			primary_key :id

			String :name

			BigDecimal :calories, :size =>[12,4]
			BigDecimal :fat, :size =>[12,4]
			BigDecimal :saturated_fat, :size =>[12,4]
			BigDecimal :cholesterol, :size =>[12,4]
			BigDecimal :sodium, :size =>[12,4]
			BigDecimal :carbohydrates, :size =>[12,4]
			BigDecimal :fiber, :size =>[12,4]
			BigDecimal :protein, :size =>[12,4]
		end
	end

	down do
		drop_table(:foods)
	end
end
