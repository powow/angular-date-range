require 'fileutils'
require 'coffee-script'

def template_file(file_name)
  contents = File.read("src/#{file_name}.html")

  template_file = <<-EOF
template = """
#{contents}
"""
module = angular.module('powow.bootstrap.date-range.template.#{file_name}', [])

registerTemplate = ($templateCache) ->
  $templateCache.put('/src/#{file_name}.html', template)

module.run(['$templateCache', registerTemplate])
  EOF
end

task :clean do
  FileUtils.rm_rf("build")
  FileUtils.mkdir_p("build/js")
  FileUtils.mkdir_p("build/coffee")
end

desc "Build a compiled version of the project"
task :build => :build_js

task :build_js => :build_coffee do
  files = ["date-range.template", "date-range-popup.template", "date-range", "manifest"].map do |f|
    File.read("build/coffee/#{f}.coffee")
  end

  src = files.map { |s| CoffeeScript.compile(s) }.join

  File.write("build/js/angular-date-range.js", src)
end

task :build_coffee => :clean do
  ["date-range", "manifest"].each do |f|
    FileUtils.cp("src/#{f}.coffee", "build/coffee")
  end

  ["date-range", "date-range-popup"].each do |template|
    src = template_file(template)
    File.write("build/coffee/#{template}.template.coffee", src)
  end
end
