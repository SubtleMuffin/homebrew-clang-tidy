class ClangTidy < Formula
  desc "Linting tools for C/C++ based on clang"
  homepage "https://clang.llvm.org/extra/clang-tidy/"
  # The LLVM Project is under the Apache License v2.0 with LLVM Exceptions
  license "Apache-2.0"
  version_scheme 1
  head "https://github.com/llvm/llvm-project.git"

  stable do
    url "https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.0/llvm-13.0.0.src.tar.xz"
    sha256 "408d11708643ea826f519ff79761fcdfc12d641a2510229eec459e72f8163020"

    resource "clang" do
      url "https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.0/clang-13.0.0.src.tar.xz"
      sha256 "5d611cbb06cfb6626be46eb2f23d003b2b80f40182898daa54b1c4e8b5b9e17e"
    end

    resource "clang-tools-extra" do
      url "https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.0/clang-tools-extra-13.0.0.src.tar.xz"
      sha256 "428b6060a28b22adf0cdf5d827abbc2ba81809f4661ede3d02b1d3fedaa3ead5"
    end
  end

  livecheck do
    url "https://github.com/llvm/llvm-project/releases/latest"
    regex(%r{href=.*?/tag/llvmorg[._-]v?(\d+(?:\.\d+)+)}i)
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build

  def install
    if build.head?
      ln_s buildpath/"clang", buildpath/"llvm/tools/clang"
      ln_s buildpath/"clang-tools-extra", buildpath/"llvm/tools/clang/tools/extra"
    else
      (buildpath/"tools/clang").install resource("clang")
      (buildpath/"tools/clang/tools/extra").install resource("clang-tools-extra")
    end

    llvmpath = build.head? ? buildpath/"llvm" : buildpath

    mkdir llvmpath/"build" do
      args = std_cmake_args
      args << "-DLLVM_ENABLE_LIBCXX=ON -DLLVM_ENABLE_PROJECTS=\"clang;clang-tools-extra\""
      args << ".."
      system "cmake", "-G", "Ninja", *args
      system "ninja", "clang-tidy"
    end

    bin.install llvmpath/"build/bin/clang-tidy"
  end

  test do
    (testpath/"test.c").write <<~EOS
      int main() { printf("hello"); }
    EOS

    assert_match "clang-diagnostic-implicit-function-declaration",
        shell_output("#{bin}/clang-tidy test.c")
  end
end
