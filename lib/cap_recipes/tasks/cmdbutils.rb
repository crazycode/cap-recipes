# -*- coding: utf-8 -*-
require "net/http"
require "uri"
require "json"

require File.expand_path(File.dirname(__FILE__) + '/http')

class CmdbService

  def self.get_app_role(cse_base, unit_code, stage)
    url = "#{cse_base}/deploy/get-server.do?deployUnitCode=#{unit_code}&stage=#{stage}"
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body

    # we convert the returned JSON data to native Ruby
    # data structure - a hash
    result = JSON.parse(data)

    # if the hash has 'Error' as a key, we raise an error
    if !result.has_key? 'success'
      raise "web service error"
    end

    unless result['success']
      raise "#{unit_code}@#{stage} get_app_role faile! return data: #{data}"
    end

    server = result['servers']
    if server.nil?
      raise "Not fout servers for #{unit_code}@#{stage}"
    end

    servers = server.collect {|s| "#{s['ip']}:#{s['sshPort']}"}
    puts "Roles: #{servers.join(', ')}"
    servers
  end


  def self.start_deploy(cse_base, unit_code, stage, version)
    url = URI.parse("#{cse_base}/deploy/start-deploy.do")
    puts "version=#{version}"
    param = { 'deployUnitCode' => unit_code, 'stage' => stage, 'deployer' => 'capistrano', 'version' => version }

    http = Net::HTTP.new(url.host, url.port)

    resp = http.post(url.path, param.to_json)
    data = resp.body

    result = JSON.parse(data)

    if !result.has_key? 'success'
      raise "web service error"
    end

    unless result['success']
      raise "#{unit_code}@#{stage} start_deploy faile! return data: #{data}"
    end

    result['deploymentId']
  end


  #deployUnitCode : 发布单元编号
  #deploymentId : 开始发布接口生成的唯一标识
  #success : 是否发布成功
  #description : 发布结果描述
  def self.complete_deploy(cse_base, unit_code, deployment_id, is_success, description)
    url = URI.parse("#{cse_base}/deploy/complete-deploy.do")

    param = { 'deployUnitCode' => unit_code, 'deploymentId' => deployment_id,
      'success' => is_success, 'description' => description }

    http = Net::HTTP.new(url.host, url.port)

    resp = http.post(url.path, param.to_json)
    data = resp.body

    result = JSON.parse(data)

    # if the hash has 'Error' as a key, we raise an error
    if !result.has_key? 'success'
      raise "web service error"
    end

    unless result['success']
      puts "#{unit_code}@#{deployment_id} complete_deploy faile! return data: #{data}"
      return false
    end

    return true
  end


  def self.get_deploy_id(file)
    unless File.exists? file
      puts "file #{file} NOT exists!"
      return nil
    end

    deploy_id = nil
    open(file, 'r') do |f|
      deploy_id = f.readline
      #if f.lines.count == 0
       # puts "empty deploy_id, please delete file: #{file}."
      #else
       # deploy_id = f.readline
      #end
    end
    deploy_id
  end

  def self.do_deploy(cse_base, unit_code, stage, version)
      codes = unit_code.split(/[,;\s]+/)
      deploy_hash = Hash.new
      codes.each {|code| deploy_hash[code] = CmdbService.start_deploy(cse_base, code, stage, version) }

      begin
        yield
        deploy_hash.each {|code, deployid| CmdbService.complete_deploy(cse_base, code, deployid, true, "通过capistrano部署成功") }
      rescue Exception => e
        deploy_hash.each {|code, deployid| CmdbService.complete_deploy(cse_base, code, deployid, false, "capistrano部署失败，撤销发布，原因：#{e.message}") }
      end
  end
end
