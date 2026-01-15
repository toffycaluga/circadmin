# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string
#  invited_by_id          :integer
#  invitations_count      :integer          default("0")
#  inviting_circus_id     :integer
#  superadmin             :boolean          default("false"), not null
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  stripe_subscription_id :string
#  had_trial              :boolean          default("false"), not null
#  circuses_count         :integer          default("0"), not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invited_by            (invited_by_type,invited_by_id)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require 'rails_helper'

RSpec.describe User, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  it "es válido con un email y contraseña" do
    user = User.new(email: "test@circadmin.com", password: "123456")
    expect(user).to be_valid
  end

  it "no es válido sin un email" do
    user = User.new(password: "123456")
    expect(user).not_to be_valid
  end

  it "no es válido sin una contraseña" do
    user = User.new(email: "test@circadmin.com")
    expect(user).not_to be_valid
  end
end
