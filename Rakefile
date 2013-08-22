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

desc "Build a compiled version of the project"
task :build do
  templates = ["date-range", "date-range-popup"].map do |template|
    template_file(template)
  end
  files = ["date-range", "manifest"].map { |f| File.read("src/#{f}.coffee") }

  src = (templates + files).map { |s| CoffeeScript.compile(s) }.join

  FileUtils.mkdir_p("build")
  File.write("build/angular-date-range.js", src)
end
