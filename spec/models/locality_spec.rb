# == Schema Information
#
# Table name: localities
#
#  id         :integer          not null, primary key
#  title      :string
#  location   :string
#  city       :string
#  start_date :date
#  end_date   :date
#  active     :boolean
#  circus_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_localities_on_circus_id  (circus_id)
#

require 'rails_helper'

RSpec.describe Locality, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
