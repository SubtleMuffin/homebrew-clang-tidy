class ClangTidy < Formula
  desc "Linting tools for C/C++ based on clang"
  homepage "https://clang.llvm.org/extra/clang-tidy/"
  # The LLVM Project is under the Apache License v2.0 with LLVM Exceptions
  license "Apache-2.0"
  version_scheme 1
  head "https://github.com/llvm/llvm-project.git"

  stable do
    url "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.1/llvm-12.0.1.src.tar.xz"
    sha256 "7d9a8405f557cefc5a21bf5672af73903b64749d9bc3a50322239f56f34ffddf"

    resource "clang" do
      url "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.1/clang-12.0.1.src.tar.xz"
      sha256 "6e912133bcf56e9cfe6a346fa7e5c52c2cde3e4e48b7a6cc6fcc7c75047da45f"
    end

    resource "clang-tools-extra" do
      url "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.1/clang-tools-extra-12.0.1.src.tar.xz"
      sha256 "65659efdf97dbed70ae0caee989936b731f249dddc46f1cb4225b2f49b232ae5"
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
