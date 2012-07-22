class AddColoringColsToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :color_type, :integer, :null => true
    add_column :jobs, :color_alignment, :integer, :null => true
  end

  def self.down
    remove_column :jobs, :color_type
    remove_column :jobs, :color_alignment
  end
end
