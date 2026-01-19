# frozen_string_literal: true

module Decidim
  module ExtraUserFields
    module Admin
      module ApplicationHelper
        def extra_user_fields_export_users_dropdown
          content_tag(:ul, style: "list-style: none; margin: 0; padding: 0;") do
            Decidim::ExtraUserFields::AdminEngine::DEFAULT_EXPORT_FORMATS.map do |format|
              content_tag(:li) do
                link_to(
                  t("decidim.admin.exports.export_as", name: t("decidim.extra_user_fields.admin.exports.users"), export_format: format.upcase),
                  AdminEngine.routes.url_helpers.extra_user_fields_export_users_path(format:),
                  style: "display: block; padding: 0.75rem 1rem; color: inherit; text-decoration: none; font-size: 0.875rem;"
                )
              end
            end.join.html_safe
          end
        end
      end
    end
  end
end
