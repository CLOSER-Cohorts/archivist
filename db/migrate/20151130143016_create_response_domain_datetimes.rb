class CreateResponseDomainDatetimes < ActiveRecord::Migration
  def change
    create_table :response_domain_datetimes do |t|
      t.string :datetime_type
      t.string :label
      t.string :format

      t.timestamps null: false
    end
  end
end
