# More info at https://github.com/guard/guard#readme

guard :rspec, cmd: "bin/rspec" do
  # App Files
  watch(%r{^app/(.+).rb$})                           {|m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(.erb|.haml|.slim)$})            {|m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller).rb$})  {|m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch("app/controllers/application_controller.rb") { "spec/controllers" }
  watch(%r{^app/views/(.+)/.*.(erb|haml|slim)$})     {|m| "spec/features/#{m[1]}_spec.rb" }
  watch("config/routes.rb")                          { "spec/routing" }
  watch(%r{^lib/(.+).rb$})                           {|m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^spec/support/(.+).rb$})                  { "spec" }

  # Capybara features specs
  watch(%r{^app/views/(.+)/.*.(erb|haml|slim)$})     {|m| "spec/features/#{m[1]}_spec.rb" }

  # Spec Files
  watch(%r{^spec/.+_spec.rb$})
  watch("spec/rails_helper.rb")        { "spec" }
  watch("spec/spec_helper.rb")         { "spec" }
  watch(%r{^spec/factories/(.+)\.rb$}) { "spec/support/factories_spec.rb" }
  watch(%r{^spec/support/(.+).rb$})    { "spec" }
end

guard :cucumber, all_on_start: false, all_after_pass: false, command_prefix: "spring", bundler: false, cli: "--no-profile --color --format pretty --no-source" do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})                      { "features" }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) {|m| Dir[File.join("**/#{m[1]}.feature")][0] || "features" }
end
