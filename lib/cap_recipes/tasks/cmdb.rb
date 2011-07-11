# -*- coding: utf-8 -*-
require "net/http"
require "uri"
require "json"

require 'cap_recipes/tasks/gitdeploy'
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
      raise "#{unit_code}@#{stage} get_app_role faile!"
    end

    server = result['servers']
    if server.nil?
      raise "Not fout servers for #{unit_code}@#{stage}"
    end

    server.collect {|s| "#{s['ip']}:#{s['sshPort']}"}
  end


  def self.start_deploy(cse_base, unit_code, stage)
    url = URI.parse("#{cse_base}/deploy/start-deploy.do")

    param = { 'deployUnitCode' => unit_code, 'stage' => stage, 'deployer' => 'capistrano', 'version' => '1.0.1' }

    http = Net::HTTP.new(url.host, url.port)

    resp = http.post(url.path, param.to_json)
    data = resp.body

    result = JSON.parse(data)

    if !result.has_key? 'success'
      raise "web service error"
    end

    unless result['success']
      raise "#{unit_code}@#{stage} start_deploy faile!"
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
      puts "#{unit_code}@#{stage} start_deploy faile!"
      return false
    end

    return true
  end

end

Capistrano::Configuration.instance(true).load do |configuration|
  set :use_sudo, true

  set :cse_base, "http://10.241.14.166:8080/cse"
  set :deploy_unit_code, ""
  set :deploy_stage, "development"

  set :deploy_id_file, ".deploy_id"

  role :app do
    CmdbService.get_app_role("#{cse_base}", deploy_unit_code, deploy_stage)
  end

  namespace :cmdb do

    def get_deploy_id
      unless File.exists? deploy_id_file
        return nil
      end

      deploy_id = nil
      open(deploy_id_file, 'r') do |f|
        if f.lines.count == 0
          puts "empty deploy_id, please delete file: #{deploy_id_file}."
        else
          deploy_id = f.readline
        end
      end
      deploy_id
    end

    task :start do
      if File.exists? deploy_id_file
        puts "Previous Deploy NOT Complete, please run 'cap cmdb:failback' first."
        exit(1)
      end

      deploy_id = CmdbService.start_deploy("#{cse_base}", deploy_unit_code, deploy_stage)

      open(deploy_id_file, 'w') do |f|
        f.write deploy_id
      end
    end


    task :failback do
      deploy_id = get_deploy_id
      complete_deploy(cse_base, deploy_unit_code, deploy_id, false, "capistrano部署失败，撤销发布")
    end

    task :done do
      deploy_id = get_deploy_id
      complete_deploy(cse_base, deploy_unit_code, deploy_id, true, "通过capistrano部署成功")
    end

    desc "deploy to tomcat"
    desc :deploy_to_tomcat do
      deploy_id = get_deploy_id() || CmdbService.start_deploy("#{cse_base}", deploy_unit_code, deploy_stage)
      puts "deploy_id=#{deploy_id}"

      gitdeploy.deploy
      tomcat.restart

      cmdb.done
    end

  end
end
