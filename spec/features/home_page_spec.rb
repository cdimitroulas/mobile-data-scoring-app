require 'rails_helper'

feature 'Home Page' do
  before do
    visit root_path
  end

  it 'can be reached' do
    expect(page.status_code).to eq(200)
  end

  scenario 'visitor can load the home page and sign up' do
    user_can_complete_mobile_number_and_click_apply
    user_can_see_modal_and_complete_sign_up
    user_is_redirected_to_complete_their_details
  end

  scenario 'registered user can sign in'

  scenario 'failed sign up returns user to sign up form' do
    user_can_complete_mobile_number_and_click_apply
    # User forgets to enter password/confirmation
    click_on('Sign up')
    expect(page).to have_css('.modal-dialog')
  end

  private

  def user_can_complete_mobile_number_and_click_apply
    expect(page).to have_field('user[mobile_number]',  type: 'text')
    fill_in 'mobile-input', with: '712341234'
    expect(page).to have_selector(:link_or_button, "Apply for a loan")
    click_on('Apply for a loan')
  end

  def user_can_see_modal_and_complete_sign_up
    expect(page).to have_css('.modal-dialog')
    expect(page).to have_field('user_password')
    expect(page).to have_field('user_password_confirmation')
    expect(page).to have_selector(:link_or_button, 'Sign up')
    fill_in 'user_password', with: '123123'
    fill_in 'user_password_confirmation', with: '123123'
    click_on('Sign up')
  end

  def user_is_redirected_to_complete_their_details
    expect(page.status_code).to eq(200)
    expect(current_url.include?('/edit')).to eql(true)
  end
end
