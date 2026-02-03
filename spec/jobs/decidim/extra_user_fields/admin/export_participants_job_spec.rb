# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraUserFields
    module Admin
      describe ExportParticipantsJob do
        subject(:job) { described_class.new }

        let(:organization) { create(:organization, extra_user_fields: {}) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:format) { "CSV" }

        it "sends an email" do
          perform_enqueued_jobs do
            ExportParticipantsJob.perform_later(organization, user, format)
          end

          email = last_email
          expect(email.subject).to include("participants")
          expect(email.to).to include(user.email)
        end

        context "when format is CSV" do
          it "uses the csv exporter" do
            export_data = double
            exporter = double(export: export_data)
            allow(Decidim::Exporters::CSV).to(
              receive(:new).with(anything, Decidim::ExtraUserFields::UserExportSerializer)
                           .and_return(exporter)
            )

            private_export = double("PrivateExport", filename: "participants-123.zip")
            allow(job).to receive(:attach_archive)
              .with(export_data, "participants", user)
              .and_return(private_export)

            mailer = double(deliver_now: true)
            allow(ExportMailer).to receive(:export).with(user, private_export).and_return(mailer)

            job.perform(organization, user, format)

            expect(Decidim::Exporters::CSV).to have_received(:new)
            expect(job).to have_received(:attach_archive)
            expect(ExportMailer).to have_received(:export)
          end
        end

        context "when format is JSON" do
          let(:format) { "JSON" }

          it "uses the json exporter" do
            export_data = double
            exporter = double(export: export_data)
            allow(Decidim::Exporters::JSON)
              .to(receive(:new).with(anything, Decidim::ExtraUserFields::UserExportSerializer))
              .and_return(exporter)

            private_export = double("PrivateExport", filename: "participants-123.zip")
            allow(job).to receive(:attach_archive)
              .with(export_data, "participants", user)
              .and_return(private_export)

            mailer = double(deliver_now: true)
            allow(ExportMailer).to receive(:export).with(user, private_export).and_return(mailer)

            job.perform(organization, user, format)

            expect(Decidim::Exporters::JSON).to have_received(:new)
            expect(job).to have_received(:attach_archive)
            expect(ExportMailer).to have_received(:export)
          end
        end

        context "when format is excel" do
          let(:format) { "Excel" }

          it "uses the excel exporter" do
            export_data = double
            exporter = double(export: export_data)
            allow(Decidim::Exporters::Excel)
              .to(receive(:new).with(anything, Decidim::ExtraUserFields::UserExportSerializer))
              .and_return(exporter)

            private_export = double("PrivateExport", filename: "participants-123.zip")
            allow(job).to receive(:attach_archive)
              .with(export_data, "participants", user)
              .and_return(private_export)

            mailer = double(deliver_now: true)
            allow(ExportMailer).to receive(:export).with(user, private_export).and_return(mailer)

            job.perform(organization, user, format)

            expect(Decidim::Exporters::Excel).to have_received(:new)
            expect(job).to have_received(:attach_archive)
            expect(ExportMailer).to have_received(:export)
          end
        end
      end
    end
  end
end
