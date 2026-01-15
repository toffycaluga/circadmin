# lib/tasks/seeds.rake
namespace :db do
  namespace :seed do
    desc "Sembrar únicamente los planes"
    task plans: :environment do
      load Rails.root.join("db/seeds/plans.rb")
      puts "✅ Planes sembrados."
    end
  end
end
