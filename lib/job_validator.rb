class JobValidator < ActiveModel::Validator

  def validate(record)
    file_types = record.sfiles.collect { |f| f.filetype }

    unless record.sfiles.size >= 2 && has_geo?(file_types)
      record.errors[:base] << ("You must select at least two files and one of them must be a geographical file.")
    end
  end

  private
  def has_tree_and_cat?(file_types)
    Sfile.subset_file_types?(file_types, "tree", "cat")
  end
  def has_geo?(file_types)
    Sfile.subset_file_types?(file_types, "geo")
  end

end