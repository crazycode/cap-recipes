# -*- coding: utf-8 -*-
require "net/http"
require "uri"
require "json"

require 'cap_recipes/tasks/gitdeploy'
require 'cap_recipes/tasks/tomcat'
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

    server.collect {|s| "#{s['ip']}:#{s['sshPort']}"}
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

end

Capistrano::Configuration.instance(true).load do |configuration|
  set :use_sudo, true

  set :cse_base, "http://10.241.14.166:8080/cse"
  set :deploy_unit_code, ""
  set :deploy_stage, "development"

  set :deploy_id_file, ".deploy_id"
  set :tag, ""

  role :app do
    CmdbService.get_app_role("#{cse_base}", deploy_unit_code, deploy_stage)
  end

  namespace :cmdb do

    task :start do
      if File.exists? deploy_id_file
        puts "Previous Deploy NOT Complete, please run 'cap cmdb:failback' first."
        exit(1)
      end

      deploy_id = CmdbService.start_deploy("#{cse_base}", deploy_unit_code, deploy_stage, tag)

      open(deploy_id_file, 'w') do |f|
        f.write deploy_id
      end
    end

    desc "set current deploy FAILBACK!"
    task :failback do
      deploy_id = CmdbService.get_deploy_id(deploy_id_file)
      unless deploy_id.nil?
        CmdbService.complete_deploy(cse_base, deploy_unit_code, deploy_id, false, "capistrano部署失败，撤销发布")
      end
    end

    desc "set current deploy success DONE!"
    task :done do
      deploy_id = CmdbService.get_deploy_id(deploy_id_file)
      puts "deploy_id=#{deploy_id}, file=#{deploy_id_file}"
      CmdbService.complete_deploy(cse_base, deploy_unit_code, deploy_id, true, "通过capistrano部署成功")
      File.delete deploy_id_file
    end

    desc "deploy to tomcat"
    task :deploy_to_tomcat do
      cmdb.start
      deploy_id = CmdbService.get_deploy_id(deploy_id_file) || CmdbService.start_deploy("#{cse_base}", deploy_unit_code, deploy_stage, tag)
      puts "deploy_id=#{deploy_id}"

      gitdeploy.deploy
      tomcat.restart

      cmdb.done
    end

  end
end
