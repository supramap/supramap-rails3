module PoyService

  BASE_URI = 'http://poyws.osc.edu/PoyService.asmx'
  #BASE_URI 'http://140.254.80.123//PoyService.asmx'

  # stop Savon from writing to stdout
  Savon.configure do |config|
    config.log = false
  end

  def PoyService.init(cluster = "oakley")
    # options for cluster at this point are 'oakley' and 'supradev'
    res = RestClient.get "#{BASE_URI}/Init?passPhase=KEOSRAKECNKHSAPJCXNLYAXBLPEMAAXOFOLVFFTGBYKNGLFRSF&resource=#{cluster}"
    return Nori.parse(res)[:int]
  end

  def PoyService.add_text_file(job_id, file_name, file_data)
    client = Savon.client("#{BASE_URI}?wsdl")
    response = client.request :add_text_file, body: {jobId: job_id, fileData: file_data, fileName: file_name.gsub(" ", "")}
    return response.body[:add_text_file_response][:add_text_file_result]
  end

  def PoyService.submit_poy(job_id, minutes = 60)
    @hours = minutes.div(60);
    @minutes = minutes.modulo(60);
    res = RestClient.get "#{BASE_URI}/SubmitPoy?jobId=#{job_id}&numberOfNodes=20&wallTimeHours=#{@hours}&wallTimeMinutes=#{@minutes}&postBackURL=supramap.osu.edu"
    return Nori.parse(res)[:string]
  end

  def PoyService.is_done?(job_id)
    res = RestClient.get "#{BASE_URI}/IsDoneYet?jobId=#{job_id}&command=poy"
    puts res
    return Nori.parse(res)[:boolean]
  end

  def PoyService.get_file(job_id, file_name)
    client = Savon.client("#{BASE_URI}?wsdl")
    response = client.request :get_text_file, body: {jobId: job_id, fileName: file_name}
    return response.body[:get_text_file_response][:get_text_file_result]

  end

  def PoyService.delete(job_id)
  end
end
