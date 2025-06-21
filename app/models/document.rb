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

# app/models/document.rb
class Document < ApplicationRecord
  belongs_to :user
  belongs_to :circus

  has_one_attached :file

  # Tags (si decides usar más adelante)
  acts_as_taggable_on :tags

  validates :title, :document_type, :file, presence: true

  DOCUMENT_TYPES = %w[
  general
  contract
  permit
  insurance
  certificate
  technical_sheet
  health
  artist_passport
  other
  ].freeze

  def contract?
    document_type == "contract"
  end

  def general?
    document_type == "general"
  end
end
