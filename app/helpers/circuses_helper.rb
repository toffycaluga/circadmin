module CircusesHelper
  def es_owner?(circus)
    return false unless current_user && circus

    @__owner_cache ||= {}
    return @__owner_cache[circus.id] if @__owner_cache.key?(circus.id)

    cu = current_user.circus_users.find_by(circus: circus)
    @__owner_cache[circus.id] = cu&.role == "owner"
  end
end
