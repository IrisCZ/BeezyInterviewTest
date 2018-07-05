# output_style = :compressed
require "compass"
# Require any additional compass plugins here.
require "autoprefixer-rails"
require "csso"

preferred_syntax = :sass
http_path = '/'
css_dir = 'assets/css'
sass_dir = 'assets/css'
images_dir = "assets/imgs"
javascripts_dir = 'assets/js'
relative_assets = true
line_comments = true


# Based on this Gist: https://gist.github.com/chriseppstein/7951379

extend Compass::Actions
Compass::Logger::ACTION_COLORS[:copy] = :green

# Relativizing a path requires us to specify the working path.
def working_path
  Dir.pwd
end

# you can change how a minified filename is constructed by changing this function.
def min_name(name)
  dir = File.dirname(name)
  base = File.basename(name)
  base, ext = base.split(".", 2)
  if dir == "."
    "#{base}.min.#{ext}"
  else
    File.join(dir, "#{base}.min.#{ext}")
  end
end

on_stylesheet_saved do |css_file|
  if top_level.environment == :development
    # Run Autoprefixer
    css = File.read(css_file)
    File.open(css_file, 'w') do |io|
      io << AutoprefixerRails.process(css, browsers: ['Android 2.3',
            'Android >= 4',
            'Chrome >= 20',
            'Firefox >= 24', # Firefox 24 is the latest ESR
            'Explorer >= 8',
            'iOS >= 6',
            'Opera >= 12',
            'Safari >= 6'
          ]
        )
    end
    # Copy .css -> .min.css and run Csso
    min = min_name(css_file)
    FileUtils.copy css_file, min
    css_min = File.read(min)
    open(min, "w") do |f|
      f << Csso.optimize(css_min, true)
    end
    logger.record :copy, "#{relativize(css_file)} => #{relativize(min)}"
  end
end
