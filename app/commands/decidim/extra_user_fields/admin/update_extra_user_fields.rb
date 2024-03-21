# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      # A command with all the business logic when updating organization's extra user fields in signup form
      class UpdateExtraUserFields < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_extra_user_fields!

          broadcast(:ok)
        end

        private

        attr_reader :form

        def update_extra_user_fields!
          Decidim.traceability.update!(
            form.current_organization,
            form.current_user,
            extra_user_fields: extra_user_fields
          )
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        def extra_user_fields
          {
            "enabled" => form.enabled || false,
            "date_of_birth" => { "enabled" => form.date_of_birth || false },
            "country" => { "enabled" => form.country || false },
            "postal_code" => { "enabled" => form.postal_code || false },
            "gender" => { "enabled" => form.gender || false },
            "phone_number" => { "enabled" => form.phone_number || false },
            "location" => { "enabled" => form.location || false },
            "underage" => { "enabled" => form.underage || false },
            "underage_limit" => form.underage_limit || 18
            # Block ExtraUserFields SaveFieldInConfig

            # EndBlock
          }
        end
        # rubocop:enable Metrics/CyclomaticComplexity
      end
    end
  end
end
