module Instruments
  # Seeds a freshly-created Instrument with the common response domains and
  # the Yes/No code list that every new instrument should start with — see
  # GH issue #87.
  #
  # The defaults are hard-coded constants. They are duplicated per-instrument
  # at create time (each Instrument owns its own ResponseDomain* and CodeList
  # rows), so changing the defaults later only affects new instruments.
  class SeedDefaults
    TEXT_DEFAULTS = [
      { label: 'Generic text', maxlen: 255 },
      { label: 'Long text',    maxlen: 5000 },
      { label: 'Other',        maxlen: 255 }
    ].freeze

    NUMERIC_DEFAULTS = [
      { label: 'How many (Integer)', numeric_type: 'Integer' },
      { label: 'How many (Float)',   numeric_type: 'Float' }
    ].freeze

    DATETIME_DEFAULTS = [
      { label: 'Date of birth', datetime_type: 'Date', format: 'DD/MM/YYYY' },
      { label: 'Generic date',  datetime_type: 'Date', format: 'DD/MM/YYYY' }
    ].freeze

    YES_NO_CODE_LIST = {
      label: 'Yes/No',
      codes: [
        { value: '1', category: 'Yes' },
        { value: '2', category: 'No'  }
      ]
    }.freeze

    def initialize(instrument)
      @instrument = instrument
    end

    def call
      ActiveRecord::Base.transaction do
        seed_text_response_domains
        seed_numeric_response_domains
        seed_datetime_response_domains
        seed_yes_no_code_list
      end
    end

    private

    def seed_text_response_domains
      TEXT_DEFAULTS.each do |attrs|
        ResponseDomainText.create!(attrs.merge(instrument: @instrument))
      end
    end

    def seed_numeric_response_domains
      NUMERIC_DEFAULTS.each do |attrs|
        ResponseDomainNumeric.create!(attrs.merge(instrument: @instrument))
      end
    end

    def seed_datetime_response_domains
      DATETIME_DEFAULTS.each do |attrs|
        ResponseDomainDatetime.create!(attrs.merge(instrument: @instrument))
      end
    end

    def seed_yes_no_code_list
      code_list = CodeList.create!(label: YES_NO_CODE_LIST[:label], instrument: @instrument)
      YES_NO_CODE_LIST[:codes].each_with_index do |code_attrs, index|
        category = Category.find_or_create_by!(label: code_attrs[:category], instrument: @instrument)
        Code.create!(
          code_list: code_list,
          category:  category,
          instrument: @instrument,
          value:     code_attrs[:value],
          order:     index + 1
        )
      end
    end
  end
end
