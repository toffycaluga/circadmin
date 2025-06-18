# == Schema Information
#
# Table name: documents
#
#  id            :integer          not null, primary key
#  title         :string
#  description   :text
#  document_type :string
#  user_id       :integer          not null
#  circus_id     :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_documents_on_circus_id  (circus_id)
#  index_documents_on_user_id    (user_id)
#

require 'rails_helper'

RSpec.describe Document, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
