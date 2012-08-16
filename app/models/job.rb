require 'cgi'
require 'color_kml'
require 'poy_service'

class Job < ActiveRecord::Base
  include ColorKML
  include SupramapExceptions
  belongs_to :project
  has_and_belongs_to_many :sfiles

  validates :name, presence: true
  validates :name, uniqueness: {:scope => :project_id}
  validates :color_alignment, presence: true, :if => "color_type == 2"
  validates :color_alignment, numericality:{ :only_integer => true } , :allow_nil => true
  validates_with JobValidator

  after_create :create_job_dir
  after_destroy :delete_job_dir

  # create job dir before job is started
  def create_job_dir
    begin
      path = "#{FILE_SERVER_ROOT}/#{self.project.user.login}/#{self.project_id}/#{self.id}/"
      logger.error("Creating job dir: #{path}")
      FileUtils.mkdir(path)
      FileUtils.chmod_R(0777, path)
    rescue
      logger.error("An error occurred creating job dir for job: #{self.id}")
      return false
    end
  end

  # delete job dir after destroyed
  def delete_job_dir
    PoyService.delete(self.job_code) unless self.job_code.nil?

    path = "#{FILE_SERVER_ROOT}/#{self.project.user.login}/#{self.project_id}/#{self.id}/"
    FileUtils.rm_r(path) if File.exist?(path)

    if self.status == "Running"
      self.stop
    end
  end

  def start
    self.status = "Abnormal Exit"
    self.save
    project_path = "#{FILE_SERVER_ROOT}/#{self.project.user.login}/#{self.project_id}/"
    job_path = project_path+"#{self.id}/"


    read_poy_script_segment =''
    sfiles.each { |f|
      case f.filetype
        when "geo"
          read_poy_script_segment<<""
        when "AA"
          read_poy_script_segment<<"read(aminoacids: (\"#{f.name}\"))\n"
        when "pre"
          read_poy_script_segment<<"read(prealigned: (\"#{f.name}\", tcm:(1,1)))\n"
        when "fasta"
          read_poy_script_segment<<"read(\"#{f.name}\")\n"
        when "cat"
          read_poy_script_segment<<"read(\"#{f.name}\")\n"
        when "tree"
          read_poy_script_segment<<"read(\"#{f.name}\")\n"
      end
    }

    file_types = sfiles.collect {|f| f.filetype}
    poy_search = ""
    unless Sfile.equal_file_types?(file_types, "tree", "cat", "geo")
      poy_search = "transform(tcm:(1,1))\nsearch(max_time:0:0:5, memory:gb:2)\nselect(best:1)"
    end
    poy_script="#{read_poy_script_segment}
set(log: \"poy.log\")
#{poy_search}
transform (static_approx)
report (\"report.nexus\", nexus, trees:(nexus))
report(\"#{name}_results.kml\", kml:(supramap, \"#{sfiles.select { |file| file.filetype == "geo" }[0].name}\"))
report(asciitrees)
report(\"#{name}_results.tre\",trees)
report(\"#{name}_results.stats\",treestats)
exit()"

    File.open(job_path + "script.psh", 'w') { |f|
      f.write(poy_script)
    }

    poy_job_id = PoyService.init()
    raise POYWSInitError if poy_job_id == -1

    self.job_code =  poy_job_id

    PoyService.add_text_file(poy_job_id, "script.poy", poy_script)
    sfiles.each { |f|
      PoyService.add_text_file(poy_job_id, f.name, File.open("#{project_path}#{f.name}", "r").read)
    }

    res = PoyService.submit_poy(poy_job_id, 60)

    self.status = "Running"
    self.save
  end

  def is_done?
    if PoyService.is_done?(self.job_code)
      begin
        path = "#{FILE_SERVER_ROOT}/#{self.project.user.login}/#{self.project_id}/#{self.id}/"
        # array of files to retrieve from the poy-ws
        files = %W[output.txt #{name}_results.kml #{name}_results.tre #{name}_results.stats report.nexus]
        files.each do |f|
          write_file_from_poy_service(self.job_code, f, path)
        end
        self.status = "Completed"
        self.save
      rescue Exception => e
        self.status = "Failed"
        self.save
        logger.error("An error occurred checking/downloading the results of a poyws job.")
        logger.error(e.message)
        logger.error(e.backtrace)
      end
    end
  end

  def create_colored_kml
    path = "#{FILE_SERVER_ROOT}/#{project.user.login}/#{project_id}/#{id}/"
    kml_file_str = File.open( path + "#{name}_results.kml", "r" ).read
    colored_kml_str = ""
    if color_type == 1
      colored_kml_str = color_kml(kml_file_str)
    elsif color_type == 2
      colored_kml_str = color_kml(kml_file_str, color_alignment)
    end

    File.open( path + "#{name}_colored_results.kml", "w") do |f|
      f.write(colored_kml_str)
    end
  end

  protected
  def write_file_from_poy_service(job_code, file_name, dir_path)
    file_string = PoyService.get_file(job_code, file_name)
    File.open(dir_path + file_name, 'w') { |f| f.write(file_string) }
  end
end
