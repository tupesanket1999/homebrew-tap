class Jester < Formula
  desc "Animated jester that tells you when Claude Code is done or needs your OK"
  homepage "https://github.com/tupesanket1999/jester"
  url "https://github.com/tupesanket1999/jester/archive/refs/tags/mac-v0.1.1.tar.gz"
  sha256 "6a4037ca62e38086f7b2752759aa0b9e7f125427734429930d3fae9e8e0d5c06"
  license "MIT"

  livecheck do
    url :stable
    regex(/^mac-v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on macos: :ventura

  def install
    system "./mac/build.sh", buildpath/"out", version.to_s
    bin.install "out/bin/jester-hook"
    bin.install "mac/jester"
    prefix.install "out/Jester.app"
  end

  service do
    run [opt_prefix/"Jester.app/Contents/MacOS/Jester"]
    keep_alive successful_exit: false
    process_type :interactive
    error_log_path var/"log/jester.log"
  end

  def caveats
    <<~EOS
      Start Jester now and at login:
        brew services start jester
      Add the Claude Code hooks (appends to your settings, with a backup):
        jester hooks install
      Watch him walk through every state:
        jester demo
    EOS
  end

  test do
    ENV["CLAUDE_CONFIG_DIR"] = testpath/"claude"
    system bin/"jester", "hooks", "install"
    assert_match "8/8", shell_output("#{bin}/jester hooks status")
    pipe_output("#{bin}/jester-hook SessionStart", '{"session_id":"brewtest","cwd":"/tmp"}', 0)
    assert_path_exists testpath/".cache/jester/sessions/brewtest.json"
    assert_path_exists prefix/"Jester.app/Contents/Resources/bots/jester/bot.json"
  end
end
