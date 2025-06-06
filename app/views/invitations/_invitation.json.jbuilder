json.extract! invitation, :id, :user_id, :circus_id, :sender_id, :message, :status, :created_at, :updated_at
json.url invitation_url(invitation, format: :json)
