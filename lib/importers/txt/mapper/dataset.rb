class Importers::TXT::Mapper::Dataset < Importers::TXT::Basic
  def initialize(thing, options)
    super do |dataset_id|
      Dataset.find dataset_id
    end
  end
end