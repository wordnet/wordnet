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
    collator = TwitterCldr::Collation::Collator.new(:pl)

    @all_by_id = Hash[all.group_by(&:role).map do |name, members|
      [name, members.sort_by { |m|
        collator.get_sort_key(m[:name].split(' ')[1])
      }]
    end]
  end
end
