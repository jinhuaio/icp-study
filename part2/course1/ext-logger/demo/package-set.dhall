let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.6.21-20220215/package-set.dhall sha256:b46f30e811fe5085741be01e126629c2a55d4c3d6ebf49408fb3b4a98e37589b
let additions = [
      { name = "ic-logger"
      , repo = "https://github.com/ninegua/ic-logger"
      , version = "ed33d022befe053b8cc1cc1f9a070daafa23dd50"
      , dependencies = [ "base" ]
      }
    ]

in  upstream # additions
