# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe RegistrationForm do
    subject do
      described_class.from_params(
        attributes
      ).with_context(
        context
      )
    end

    let(:organization) { create(:organization) }
    let(:name) { "User" }
    let(:nickname) { "justme" }
    let(:email) { "user@example.org" }
    let(:password) { "S4CGQ9AM4ttJdPKS" }
    let(:password_confirmation) { password }
    let(:tos_agreement) { "1" }
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
        name: name,
        nickname: nickname,
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        tos_agreement: tos_agreement,
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

    let(:context) do
      {
        current_organization: organization
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

    context "when the email is a disposable account" do
      let(:email) { "user@mailbox92.biz" }

      it { is_expected.to be_invalid }
    end

    context "when the name is not present" do
      let(:name) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the nickname is not present" do
      let(:nickname) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the email is not present" do
      let(:email) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the email already exists" do
      context "and a user has the email" do
        let!(:user) { create(:user, organization: organization, email: email) }

        it { is_expected.to be_invalid }

        context "and is pending to accept the invitation" do
          let!(:user) { create(:user, organization: organization, email: email, invitation_token: "foo", invitation_accepted_at: nil) }

          it { is_expected.to be_invalid }
        end
      end

      context "and a user_group has the email" do
        let!(:user_group) { create(:user_group, organization: organization, email: email) }

        it { is_expected.to be_invalid }
      end
    end

    context "when the nickname already exists" do
      context "and a user has the nickname" do
        let!(:user) { create(:user, organization: organization, nickname: nickname.upcase) }

        it { is_expected.to be_invalid }

        context "and is pending to accept the invitation" do
          let!(:user) { create(:user, organization: organization, nickname: nickname, invitation_token: "foo", invitation_accepted_at: nil) }

          it { is_expected.to be_valid }
        end
      end

      context "and a user_group has the nickname" do
        let!(:user_group) { create(:user_group, organization: organization, nickname: nickname) }

        it { is_expected.to be_invalid }
      end
    end

    context "when the nickname is too long" do
      let(:nickname) { "verylongnicknamethatcreatesanerror" }

      it { is_expected.to be_invalid }
    end

    context "when the name is an email" do
      let(:name) { "test@example.org" }

      it { is_expected.to be_invalid }
    end

    context "when the nickname has spaces" do
      let(:nickname) { "test example" }

      it { is_expected.to be_invalid }
    end

    context "when the password is not present" do
      let(:password) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the password is weak" do
      let(:password) { "aaaabbbbcccc" }

      it { is_expected.to be_invalid }
    end

    context "when the password confirmation is not present" do
      let(:password_confirmation) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the password confirmation is different from password" do
      let(:password_confirmation) { "invalid" }

      it { is_expected.to be_invalid }
    end

    context "when the tos_agreement is not accepted" do
      let(:tos_agreement) { "0" }

      it { is_expected.to be_invalid }
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
