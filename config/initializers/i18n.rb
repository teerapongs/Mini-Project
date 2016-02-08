if Rails.env.test?

  # raises exception when there is a wrong/no i18n key
  module I18n
    def self.missing_translation_handler(*args)
      raise "i18n #{args.first}"
    end
  end

  I18n.exception_handler = :missing_translation_handler

end
