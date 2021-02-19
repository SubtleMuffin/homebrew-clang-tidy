class ClangTidy < Formula
  desc "Linting tools for C/C++ based on clang"
  homepage "https://clang.llvm.org/extra/clang-tidy/"
  # The LLVM Project is under the Apache License v2.0 with LLVM Exceptions
  license "Apache-2.0"
  version_scheme 1
  head "https://github.com/llvm/llvm-project.git"

  stable do
    url "https://github.com/llvm/llvm-project/releases/download/llvmorg-11.1.0/llvm-11.1.0.src.tar.xz"
    sha256 "ce8508e318a01a63d4e8b3090ab2ded3c598a50258cc49e2625b9120d4c03ea5"

    resource "clang" do
      url "https://github.com/llvm/llvm-project/releases/download/llvmorg-11.1.0/clang-11.1.0.src.tar.xz"
      sha256 "0a8288f065d1f57cb6d96da4d2965cbea32edc572aa972e466e954d17148558b"
    end

    resource "clang-tools-extra" do
      url "https://github.com/llvm/llvm-project/releases/download/llvmorg-11.1.0/clang-tools-extra-11.1.0.src.tar.xz"
      sha256 "76707c249de7a9cde3456b960c9a36ed9bbde8e3642c01f0ef61a43d61e0c1a2"
    end
  end

  livecheck do
    url "https://github.com/llvm/llvm-project/releases/latest"
    regex(%r{href=.*?/tag/llvmorg[._-]v?(\d+(?:\.\d+)+)}i)
  end

  bottle do
    root_url "https://github.com/SubtleMuffin/homebrew-formulas/releases/download/11.1.0"
    cellar :any_skip_relocation
    sha256 "e5c9059b8248f279242486ed60ca197e2f97183027df9c5b506c01817e59f536" => :big_sur
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
