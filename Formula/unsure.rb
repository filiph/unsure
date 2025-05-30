class Unsure < Formula
  desc "Calculator for numbers with uncertainty"
  homepage "https://github.com/filiph/unsure"
  url "https://github.com/filiph/unsure/archive/v0.4.0.tar.gz"
  sha256 "d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed"
  license "MIT"

  depends_on "dart" => :build

  def install
    system "dart", "pub", "get"
    system "dart", "compile", "exe", "bin/unsure.dart", "-o", "unsure"
    bin.install "unsure"
  end

  test do
    # Test that the binary runs and produces expected output
    output = shell_output("#{bin}/unsure \"5\"")
    assert_match "5", output
    
    # Test uncertain calculation
    output = shell_output("#{bin}/unsure \"4~6 * 2\"")
    assert_match "8", output
  end
end 