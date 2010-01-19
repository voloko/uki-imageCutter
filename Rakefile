desc "Run thin"
task :start do
  sh "sudo thin -s 1 -C thin.yaml -R thin.ru start"
end

desc "Run thin"
task :restart do
  sh "sudo thin -s 1 -C thin.yaml -R thin.ru restart"
end

desc "Stop thin"
task :stop do
  sh "sudo thin -s 1 -C thin.yaml -R thin.ru stop"
end

