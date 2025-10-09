# == Schema Information
#
# Table name: circuses
#
#  id                 :integer          not null, primary key
#  name               :string
#  description        :text
#  country            :string
#  currency           :string
#  active             :boolean          default("true")
#  user_id            :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_customer_id :string
#  had_trial          :boolean          default("false"), not null
#
# Indexes
#
#  index_circuses_on_stripe_customer_id  (stripe_customer_id)
#  index_circuses_on_user_id             (user_id)
#

require "rails_helper"

RSpec.describe Circus, type: :model do
  it { should validate_presence_of(:name) }       # si agregas validación
  it { should validate_presence_of(:country) }    # idem
  it { should validate_presence_of(:currency) }   # idem
  it { should belong_to(:user).optional(false) }  # ajusta según tu modelo
  it { should have_many(:circus_users).dependent(:destroy) } # si lo definiste así
end
