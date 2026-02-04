# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join("spec", "decidim_dummy_app"))

Dir[File.join(__dir__, "support", "**", "*.rb")].each { |f| require f }

require "decidim/dev/test/base_spec_helper"
