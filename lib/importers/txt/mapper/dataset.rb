class Importers::TXT::Mapper::Dataset < Importers::TXT::Basic
  def initialize(thing, options)
    super(thing, options) do |dataset_id|
      ::Dataset.find dataset_id
    end
  end
end
