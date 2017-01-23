class Aeneas < Formula
  desc "Python/C library and set of tools to synchronize audio and text"
  homepage "http://www.readbeyond.it/aeneas/"
  url "https://github.com/readbeyond/aeneas/archive/v1.7.1.tar.gz"
  sha256 "b49d80c4059d66f2a8bed114757fd10efc1f1ecff563da96be67149b3e6af83c"
  head "https://github.com/readbeyond/aeneas.git"

  bottle do
    cellar :any
    sha256 "d41f1068fff0b6687d52523fc23f5553074093f26a470d719ef7444a5b9cff99" => :el_capitan
    sha256 "f2262f714c29d7fe662c97270675df81bcfee692e21f7535f31e102152258e8b" => :yosemite
    sha256 "6116f2c5fcf947ed4d6381f81af3e548f98cffa586faf1456fc2384084c39107" => :mavericks
  end

  option "without-python", "Build without Python 2.7 support"

  depends_on "espeak" => :recommended
  depends_on "ffmpeg" => :recommended
  depends_on :python3 => :optional
  depends_on "homebrew/python/numpy"

  resource "beautifulsoup4" do
    url "https://pypi.python.org/packages/86/ea/8e9fbce5c8405b9614f1fd304f7109d9169a3516a493ce4f7f77c39435b7/beautifulsoup4-4.5.1.tar.gz"
    sha256 "3c9474036afda9136aac6463def733f81017bf9ef3510d25634f335b0c87f5e1"
  end

  resource "lxml" do
    url "https://pypi.python.org/packages/11/1b/fe6904151b37a0d6da6e60c13583945f8ce3eae8ebd0ec763ce546358947/lxml-3.6.0.tar.gz"
    sha256 "9c74ca28a7f0c30dca8872281b3c47705e21217c8bc63912d95c9e2a7cac6bdf"
  end

  def install
    Language::Python.each_python(build) do |python, version|
      dest_path = lib/"python#{version}/site-packages"
      dest_path.mkpath
      vendor_path = libexec/"vendor/lib/python#{version}/site-packages"
      ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
      resources.each do |r|
        r.stage do
          system python, *Language::Python.setup_install_args(libexec/"vendor")
        end
      end
      (dest_path/"homebrew-aeneas-vendor.pth").write "#{vendor_path}\n"

      system python, *Language::Python.setup_install_args(prefix)
      dest_path.install "VERSION"
      dest_path.install "check_dependencies.py"
    end
  end

  test do
    ENV["PYTHONIOENCODING"] = "UTF-8"
    system "python", "-m", "aeneas.diagnostics"
    system "python", "-m", "aeneas.tools.synthesize_text", "list", "This is a test|with two lines", "eng", "-v", "test.wav"
  end
end
