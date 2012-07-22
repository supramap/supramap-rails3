class JobValidator < ActiveModel::Validator

  def validate(record)
    if record.sfiles.size < 2 || record.sfiles.select { |file| file.filetype == "geo" }.size != 1
      record.errors[:base] << ("You must select one csv file, and at least one other file")
    end
  end
end