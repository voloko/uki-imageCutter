namespace :dev do
  desc "Run thin"
  task :start do
    sh "thin -s 1 -C conf/thin.yaml start"
  end

  desc "Run thin"
  task :restart do
    sh "thin -s 1 -C conf/thin.yaml restart"
  end

  desc "Stop thin"
  task :stop do
    sh "thin -s 1 -C conf/thin.yaml stop"
  end
end

namespace :prod do
  desc "Run thin development"
  task :start do
    sh "thin -s 2 -C conf/prod.yaml start"
  end

  desc "Run thin"
  task :restart do
    sh "thin -s 2 -C conf/prod.yaml restart"
  end

  desc "Stop thin"
  task :stop do
    sh "thin -s 2 -C conf/prod.yaml stop"
  end
end
