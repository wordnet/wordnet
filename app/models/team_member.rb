require 'csv'

class TeamMember
  def self.all
    @all ||= begin
      path = Rails.root.join('db', 'team.csv')
      metadata = CSV.foreach(path, headers: true).to_a.map(&:to_h)
      metadata.map do |r|
        Hashie::Mash[r]
      end
    end
  end

  def self.all_by_role
    @all_by_id = all.group_by(&:role)
  end
end
