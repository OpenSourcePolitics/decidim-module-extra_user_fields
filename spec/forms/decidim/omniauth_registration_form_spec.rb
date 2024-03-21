# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OmniauthRegistrationForm do
    subject do
      described_class.from_params(
        attributes
      ).with_context(
        current_organization: organization
      )
    end

    let(:organization) { create(:organization) }
    let(:name) { "Facebook User" }
    let(:email) { "user@from-facebook.com" }
    let(:provider) { "facebook" }
    let(:uid) { "12345" }
    let(:oauth_signature) { OmniauthRegistrationForm.create_signature(provider, uid) }
    let(:country) { "Argentina" }
    let(:date_of_birth) { "01/01/2000" }
    let(:gender) { "other" }
    let(:location) { "Paris" }
    let(:phone_number) { "0123456789" }
    let(:postal_code) { "75001" }
    let(:underage) { "0" }
    let(:statutory_representative_email) { nil }

    let(:attributes) do
      {
        email: email,
        email_verified: true,
        name: name,
        provider: provider,
        uid: uid,
        oauth_signature: oauth_signature,
        avatar_url: "http://www.example.org/foo.jpg",
        country: country,
        postal_code: postal_code,
        date_of_birth: date_of_birth,
        gender: gender,
        phone_number: phone_number,
        location: location,
        underage: underage,
        statutory_representative_email: statutory_representative_email
      }
    end

    before do
      organization.update!(
        extra_user_fields: {
          "enabled" => true,
          "date_of_birth" => { "enabled" => true },
          "postal_code" => { "enabled" => true },
          "gender" => { "enabled" => true },
          "country" => { "enabled" => true },
          "phone_number" => { "enabled" => true },
          "location" => { "enabled" => true },
          "underage" => { "enabled" => true },
          "underage_limit" => 18
        }
      )
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when name is blank" do
      let(:name) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when email is blank" do
      let(:email) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when provider is blank" do
      let(:provider) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when uid is blank" do
      let(:uid) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when country is blank" do
      let(:country) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when postal_code is blank" do
      let(:postal_code) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when date_of_birth is blank" do
      let(:date_of_birth) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when gender is blank" do
      let(:gender) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when phone_number is blank" do
      let(:phone_number) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when location is blank" do
      let(:location) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when underage is blank" do
      let(:underage) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when statutory_representative_email is blank" do
      let(:underage) { "1" }
      let(:statutory_representative_email) { nil }

      it { is_expected.not_to be_valid }
    end

    context "when the user is underage but did not tick the underage" do
      let(:date_of_birth) { "01/01/2010" }
      let(:underage) { "0" }

      it { is_expected.not_to be_valid }
    end
  end
end
