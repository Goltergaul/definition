# frozen_string_literal: true

require "pathname"

I18n.load_path += Dir[File.join(File.expand_path(Pathname(__dir__).join("../../config/locales/")), "*.yml")]
