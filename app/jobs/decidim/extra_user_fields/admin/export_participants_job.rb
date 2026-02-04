# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      class ExportParticipantsJob < ApplicationJob
        queue_as :exports
        include Decidim::PrivateDownloadHelper

        def perform(organization, user, format)
          collection = organization.users.not_deleted
          export_data = Decidim::Exporters.find_exporter(format).new(collection,
                                                                     Decidim::ExtraUserFields::UserExportSerializer).export
          name = "participants"

          private_export = attach_archive(export_data, name, user)

          ExportMailer.export(user, private_export).deliver_now
        end
      end
    end
  end
end
