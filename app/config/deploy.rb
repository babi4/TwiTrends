$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
require 'bundler/capistrano'


set :application, "TwiTrend"
set :repository,  "git@github.com:babi4/TwiTrends.git"
set :rails_env, "production" #TODO change variable

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :domain, "main@trends.babi4.com"
 
role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                         # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run
set :branch, "master"
set :unicorn_conf, "/home/main/#{application}/current/unicorn.rb"
set :unicorn_pid, "/home/main/#{application}/shared/pids/unicorn.pid"

set :use_sudo, false

set :deploy_to, "/home/main/#{application}"
set :deploy_via, :remote_cache



set :rvm_ruby_string, '1.9.2@stream'
set :rvm_type, :user


after 'deploy:update_code', 'symlinks:set'

namespace :symlinks do
  task :set, :roles => :app  do
    ## Здесь для примера вставлен только один конфиг с приватными данными - database.yml. 
    #Обычно для таких вещей создают папку /srv/myapp/shared/config и кладут файлы туда. 
    #При каждом деплое создаются ссылки на них в нужные места приложения.    

    run "rm -f #{current_release}/database.yml"
    run "ln -s #{deploy_to}/shared/config/database.yml #{current_release}/database.yml"

  end
end


after "deploy", "deploy:restart_daemons" 

# Далее идут правила для перезапуска unicorn. Их стоит просто принять на веру - они работают.
# В случае с Rails 3 приложениями стоит заменять bundle exec unicorn_rails на bundle exec unicorn
namespace :deploy do
  task :restart do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D; fi"
  end
  task :start do
    run "bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
  end
  task :stop do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end

  task :restart_daemons, :roles => :app do
    run "ps auxww | awk '$0~/spyder|gen/&&$0!~/awk/{print $2}'| xargs kill 2>/dev/null"
    run "cd /home/main/#{application}/current/scripts && screen -m -d -S gen  ruby gen_top.rb"
    run "cd /home/main/#{application}/current/scripts && screen -m -d -S spyder ruby spyder.rb"
  end


end



# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end