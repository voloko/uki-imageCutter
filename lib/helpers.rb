require 'base64'
require 'fileutils'
require 'tempfile'

def optimize_png(data)
  f = Tempfile.new(['opt_png', '.png'])
  f.write(data)
  f.close()
  p = f.path
  variants = ['.opti', '.crush', '.crush.opti', '.opti.crush']

  `optipng -q -nc -o7 #{p} -out #{p}.opti`
	`pngcrush -q -rem alla -brute #{p} #{p}.crush`
	`optipng -q -nc -o7 -i0 #{p}.crush -out #{p}.crush.opti`
	`pngcrush -q -rem alla -brute #{p}.opti #{p}.opti.crush`
  suffix = variants.max { |a, b| File.size(p + a) <=> File.size(p + b) }
  FileUtils.rm(p)
  FileUtils.mv(p + suffix, p)
  variants.each { |v| FileUtils.rm(p + v) rescue nil }
  return File.read(p)
end

def optimize_gif(data)
  f = Tempfile.new(['opt_gif', '.png'])
  f.write(data)
  f.close()
  p = f.path
  
  `convert #{p} #{p}.gif`
  return File.read("#{p}.gif")
end

def encode64(str)
  Base64.encode64(str).gsub("\n", '')
end

