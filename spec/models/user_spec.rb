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
