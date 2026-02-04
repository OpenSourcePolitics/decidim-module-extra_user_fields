# frozen_string_literal: true

require "spec_helper"

def fill_registration_form
  fill_in :registration_user_name, with: "Nikola Tesla"
  fill_in :registration_user_email, with: "nikola.tesla@example.org"
  fill_in :registration_user_password, with: "sekritpass123"
  page.check("registration_user_newsletter")
  page.check("registration_user_tos_agreement")
end

def fill_extra_user_fields(phone_number: "0123456789")
  fill_date_of_birth
  select "Other", from: :registration_user_gender
  select "Argentina", from: :registration_user_country
  fill_in :registration_user_postal_code, with: "00000"
  fill_in :registration_user_phone_number, with: phone_number
  fill_in :registration_user_location, with: "Cahors"
end

def submit_registration_form(disable_pattern_validation: false)
  if disable_pattern_validation
    page.execute_script(<<~JS)
      const phoneInput = document.querySelector('#registration_user_phone_number');
      if (phoneInput && phoneInput.hasAttribute('pattern')) {
        phoneInput.setAttribute('data-original-pattern', phoneInput.getAttribute('pattern'));
        phoneInput.removeAttribute('pattern');
      }
    JS
  end

  within "form.new_user" do
    find("*[type=submit]").click
  end

  sleep 0.5
end

def wait_for_field_error(field, timeout: 5)
  Timeout.timeout(timeout) do
    loop do
      has_error = page.has_css?("label[for='registration_user_#{field}'] .form-error", wait: 0.5) ||
                  page.has_css?("label[for='registration_user_#{field}'] .error", wait: 0.5) ||
                  page.has_css?("#registration_user_#{field}.is-invalid-input", wait: 0.5) ||
                  page.has_css?("#registration_user_#{field}[aria-invalid='true']", wait: 0.5) ||
                  page.has_css?(".field_with_errors #registration_user_#{field}", wait: 0.5) ||
                  page.has_css?("#registration_user_#{field}_error", wait: 0.5)

      return true if has_error

      sleep 0.2
    end
  end
rescue Timeout::Error
  false
end

def expect_validation_error_on_field(field)
  expect(page).to have_no_content("message with a confirmation link has been sent", wait: 3)

  has_form = page.has_css?("form.new_user", wait: 3)
  expect(has_form).to be(true), "Expected to stay on registration page with form visible"

  field_has_error = wait_for_field_error(field, timeout: 5)

  expect(field_has_error).to be(true),
                             "Expected field '#{field}' to have validation error. Current path: #{page.current_path}"

  error_message_found = page.has_content?("is invalid", wait: 2) ||
                        page.has_content?("invalid", wait: 2) ||
                        page.has_content?("format", wait: 2) ||
                        page.has_content?("error", wait: 2, case_sensitive: false)

  expect(error_message_found).to be(true), "Expected to find error message for field '#{field}'"
end

describe "Extra user fields" do
  shared_examples_for "mandatory extra user fields" do |field|
    it "displays #{field} as mandatory" do
      within "label[for='registration_user_#{field}']" do
        expect(page).to have_css("span.label-required")
      end
    end
  end

  let(:organization) { create(:organization, extra_user_fields:) }
  let!(:terms_and_conditions_page) { Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization:) }
  let(:extra_user_fields) do
    {
      "enabled" => true,
      "date_of_birth" => date_of_birth,
      "postal_code" => postal_code,
      "gender" => gender,
      "country" => country,
      "phone_number" => phone_number,
      "location" => location
    }
  end

  let(:date_of_birth) { { "enabled" => true } }
  let(:postal_code) { { "enabled" => true } }
  let(:country) { { "enabled" => true } }
  let(:gender) { { "enabled" => true } }
  let(:phone_number) do
    { "enabled" => true, "pattern" => phone_number_pattern, "placeholder" => nil }
  end
  let(:phone_number_pattern) { "^(\\+34)?[0-9 ]{9,12}$" }
  let(:location) { { "enabled" => true } }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  it "contains extra user fields" do
    within "#card__extra_user_fields" do
      expect(page).to have_content("Date of birth")
      expect(page).to have_content("Gender")
      expect(page).to have_content("Country")
      expect(page).to have_content("Postal code")
      expect(page).to have_content("Phone Number")
      expect(page).to have_content("Location")
    end
  end

  it "allows to create a new account" do
    fill_registration_form
    fill_extra_user_fields
    submit_registration_form

    expect(page).to have_content("message with a confirmation link has been sent")
  end

  context "with phone number pattern blank" do
    let(:phone_number_pattern) { nil }

    it "allows to create a new account" do
      fill_registration_form
      fill_extra_user_fields
      submit_registration_form

      expect(page).to have_content("message with a confirmation link has been sent")
    end
  end

  context "with phone number pattern not compatible with number" do
    let(:phone_number_pattern) { "^(\\+34)?[0-1 ]{9,12}$" }

    it "does not allow to create a new account" do
      fill_registration_form
      fill_extra_user_fields(phone_number: "0123456789")
      submit_registration_form(disable_pattern_validation: true)

      expect_validation_error_on_field("phone_number")
    end
  end

  it_behaves_like "mandatory extra user fields", "date_of_birth"
  it_behaves_like "mandatory extra user fields", "gender"
  it_behaves_like "mandatory extra user fields", "country"
  it_behaves_like "mandatory extra user fields", "postal_code"
  it_behaves_like "mandatory extra user fields", "phone_number"
  it_behaves_like "mandatory extra user fields", "location"

  context "when extra_user_fields is disabled" do
    let(:organization) { create(:organization, :extra_user_fields_disabled) }

    it "does not contain extra user fields" do
      expect(page).to have_no_content("Date of birth")
      expect(page).to have_no_content("Gender")
      expect(page).to have_no_content("Country")
      expect(page).to have_no_content("Postal code")
      expect(page).to have_no_content("Phone Number")
      expect(page).to have_no_content("Location")
    end

    it "allows to create a new account" do
      fill_registration_form
      submit_registration_form

      expect(page).to have_content("message with a confirmation link has been sent")
    end
  end
end
