class Pygame < Formula
  desc "Set of Python modules designed for writing video games"
  homepage "http://pygame.org"
  url "https://bitbucket.org/pygame/pygame/get/1.9.2.tar.gz"
  sha256 "0d8d1b04e345806e1fc0dc1b062bbb7c0841f8f120edcb1b9fe78257293b17ff"
  head "https://bitbucket.org/pygame/pygame", :using => :hg

  option "without-python", "Build without python2 support"
  depends_on :python3 => :optional
  depends_on "sdl"
  depends_on "sdl_image"
  depends_on "sdl_mixer"
  depends_on "sdl_ttf"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "portmidi"
  depends_on "homebrew/python/numpy"
  depends_on "freetype"

  def install
    # We provide a "Setup" file based on the "Setup.in" because the detection
    # code in config.py does not know about the HOMEBREW_PREFIX, assumes SDL
    # is built as a framework and cannot find the Frameworks inside of Xcode.
    mv "Setup.in", "Setup"
    sdl = Formula["sdl"].opt_prefix
    sdl_ttf = Formula["sdl_ttf"].opt_prefix
    sdl_image = Formula["sdl_image"].opt_prefix
    sdl_mixer = Formula["sdl_mixer"].opt_prefix
    portmidi = Formula["portmidi"].opt_prefix
    inreplace "Setup" do |s|
      s.gsub!(/^SDL =.*$/, "SDL = -I#{sdl}/include/SDL -Ddarwin -lSDL")
      s.gsub!(/^FONT =.*$/, "FONT = -I#{sdl_ttf}/include/SDL -lSDL_ttf")
      s.gsub!(/^IMAGE =.*$/, "IMAGE = -I#{sdl_image}/include/SDL -lSDL_image")
      s.gsub!(/^MIXER =.*$/, "MIXER = -I#{sdl_mixer}/include/SDL -lSDL_mixer")
      s.gsub!(/^PNG =.*$/, "PNG = -lpng")
      s.gsub!(/^JPEG =.*$/, "JPEG = -ljpeg")
      s.gsub!(/^PORTMIDI =.*$/, "PORTMIDI = -I#{portmidi}/include/ -lportmidi")
      s.gsub!(/^PORTTIME =.*$/, "PORTTIME = -I#{portmidi}/include/ -lportmidi")
      s.gsub!(/^FREETYPE =.*$/, "FREETYPE = -I#{Formula["freetype"].opt_include}/freetype2 -lfreetype")
    end

    # Manually append what is the default for PyGame on the Mac
    system "cat Setup_Darwin.in >> Setup"

    # Remove ogg from test if no OGG Vorbis support
    unless Formula["libvorbis"].installed?
      inreplace "test/mixer_music_test.py", "formats = ['ogg', 'wav']", "formats = ['wav']"
    end

    Language::Python.each_python(build) do |python, version|
      ENV.prepend_create_path "PYTHONPATH", lib+"python#{version}/site-packages"
      system python, *Language::Python.setup_install_args(prefix)
    end
  end

  test do
    Language::Python.each_python(build) do |python, version|
      ENV.prepend_create_path "PYTHONPATH", lib+"python#{version}/site-packages"
      system python, "-m", "pygame.tests.__main__", "--time_out", "300", "-p", python
    end
  end
end
