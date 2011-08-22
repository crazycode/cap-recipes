# -*- coding: utf-8 -*-
# =============================================================================
# GENERAL SETTINGS
# =============================================================================

role :app, "10.241.14.166"

set :application,  "demo"
set :deploy_to,  "/var/apps/#{application}"
# set :deploy_via, :remote_cache
# set :scm, :git
# set :repository, "deploy@dev.demo.com:/home/demo.git"
# set :git_enable_submodules, 1
# set :keep_releases, 3

set :user, "pm030"
set :use_sudo, true

ssh_options[:paranoid] = false
default_run_options[:pty] = true

# 自定义变量

set :build_workspace, "/home/tanglq/pay/cmdb"
set :release_dir, "/tmp/cmdb_release"
set :upload_dir, "/tmp/cmdb_upload"


# =============================================================================
# RECIPE INCLUDES
# =============================================================================

require 'rubygems'
# for development
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'cap_recipes/tasks/sdpjenkins'
