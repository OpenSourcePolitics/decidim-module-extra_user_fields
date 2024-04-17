# frozen_string_literal: true

require "spec_helper"

describe "Admin manages officializations" do
  include_context "with filterable context"

  let(:model_name) { Decidim::User.model_name }
  let(:resource_controller) { Decidim::Admin::OfficializationsController }

  let(:organization) { create(:organization) }

  let!(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    within ".layout-nav" do
      click_on "Participants"
    end
  end

  it "includes export dropdown button" do
    within ".sidebar-menu" do
      click_on "Participants"
    end

    expect(page).to have_content("Export")
  end
end
